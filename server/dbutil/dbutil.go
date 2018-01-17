package dbutil

import (
	"crypto/md5"
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/mattn/go-sqlite3"
	"github.com/pmezard/go-difflib/difflib"
)

const defaultExperimentID = 1

// Bootstrap creates the necessary tables for the output DB. It is safe to call on a
// DB that is already bootstrapped.
func Bootstrap(db *sql.DB) error {
	const (
		createUsers = `CREATE TABLE IF NOT EXISTS users (
			id INTEGER, github_username TEXT, auth TEXT, role INTEGER,
			PRIMARY KEY (id))`
		createExperiments = `CREATE TABLE IF NOT EXISTS experiments (
			id INTEGER, name TEXT UNIQUE, description TEXT,
			PRIMARY KEY (id))`
		// TODO: consider a unique constrain to avoid importing identical pairs
		createFilePairs = `CREATE TABLE IF NOT EXISTS file_pairs (
			id INTEGER, name_a TEXT, name_b TEXT, hash_a TEXT, hash_b TEXT,
			content_a TEXT, content_b TEXT, diff TEXT,experiment_id INTEGER,
			PRIMARY KEY (id),
			FOREIGN KEY(experiment_id) REFERENCES experiments(id))`
		createAssignments = `CREATE TABLE IF NOT EXISTS assignments (
			user_id INTEGER, pair_id INTEGER, experiment_id INTEGER,
			answer INTEGER, duration INTEGER,
			PRIMARY KEY (user_id, pair_id),
			FOREIGN KEY (user_id) REFERENCES users(id),
			FOREIGN KEY (pair_id) REFERENCES file_pairs(id),
			FOREIGN KEY (experiment_id) REFERENCES experiments(id))`
	)

	if _, err := db.Exec(createUsers); err != nil {
		return err
	}

	if _, err := db.Exec(createExperiments); err != nil {
		return err
	}

	if _, err := db.Exec(createFilePairs); err != nil {
		return err
	}

	if _, err := db.Exec(createAssignments); err != nil {
		return err
	}

	return nil
}

// Initialize populates the DB with default values. It is safe to call on a
// DB that is already initialized
func Initialize(db *sql.DB) error {
	_, err := db.Exec(`
		INSERT OR IGNORE INTO experiments (id, name, description)
		VALUES ($1, 'default', 'Default experiment')`,
		defaultExperimentID)

	if err != nil {
		return err
	}

	return nil
}

// Options for the ImportFiles method. Logger is optional, if it is not provided
// the default stderr will be used.
type Options struct {
	Logger *log.Logger
}

// ImportFiles imports pairs of files from the origin to the destination DB.
// It copies the contents and processes the needed data (md5 hash, diff)
func ImportFiles(originDB, destDB *sql.DB, opts Options) (success, failures int64, e error) {
	logger := log.New(os.Stderr, "", log.LstdFlags) // Default log to stderr

	if opts.Logger != nil {
		logger = opts.Logger
	}

	rows, err := originDB.Query("SELECT * FROM files;")
	if err != nil {
		return 0, 0, err
	}

	tx, err := destDB.Begin()

	insert, err := tx.Prepare(`INSERT INTO file_pairs
		(name_a, name_b, hash_a, hash_b, content_a, content_b, diff, experiment_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8);`)

	if err != nil {
		return 0, 0, err
	}

	for rows.Next() {
		var nameA, nameB, contentA, contentB, diffText string
		if err := rows.Scan(&nameA, &nameB, &contentA, &contentB); err != nil {
			return success, failures, err
		}

		diffText, err := diff(nameA, nameB, contentA, contentB)
		if err != nil {
			logger.Printf(
				"Failed to create diff for files:\n - %q\n - %q\nerror: %v\n",
				nameA, nameB, err)
			failures++
			continue
		}

		res, err := insert.Exec(nameA, nameB,
			md5hash(contentA), md5hash(contentB),
			contentA, contentB,
			diffText,
			defaultExperimentID)

		if err != nil {
			logger.Println(err)
			failures++
			continue
		}

		rowsAffected, _ := res.RowsAffected()
		success += rowsAffected
	}

	if err := tx.Commit(); err != nil {
		return success, failures, err
	}

	if err := rows.Err(); err != nil {
		return success, failures, err
	}

	return success, failures, nil
}

func md5hash(text string) string {
	return fmt.Sprintf("%x", md5.Sum([]byte(text)))
}

func diff(nameA, nameB, contentA, contentB string) (string, error) {
	diff := difflib.UnifiedDiff{
		A:        difflib.SplitLines(contentA),
		B:        difflib.SplitLines(contentB),
		FromFile: nameA,
		ToFile:   nameB,
		Context:  3,
	}

	return difflib.GetUnifiedDiffString(diff)
}
