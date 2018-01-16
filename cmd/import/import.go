/*
Tool to import pairs of files from an input sqlite database to another database.

Usage: import <path-to-origin.db> <path-to-destination.db>

The origin database is assumed to have the following table:
CREATE TABLE files (name_a TEXT, name_b TEXT, content_a TEXT, content_b TEXT);
*/
package main

import (
	"crypto/md5"
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	args := os.Args

	if len(args) != 3 {
		printHelp()
		return
	}

	originPath := args[1]
	destPath := args[2]

	// TODO: check origin path exists

	originDB, err := sql.Open("sqlite3", originPath)
	if err != nil {
		log.Fatal(err)
	}
	defer originDB.Close()

	destDB, err := sql.Open("sqlite3", destPath)
	if err != nil {
		log.Fatal(err)
	}
	defer destDB.Close()

	if err = bootstrap(destDB); err != nil {
		log.Fatal(err)
	}

	nFiles, err := importFiles(originDB, destDB)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Imported %v file pairs successfully\n", nFiles)
}

func printHelp() {
	// TODO: Improve help message
	fmt.Println("Usage: import <path-to-origin.db> <path-to-destination.db>")
}

// bootstrap creates the necessary tables for the output DB. It is safe to call on a
// DB that is already bootstrapped.
func bootstrap(db *sql.DB) error {
	_, err := db.Exec(`
		CREATE TABLE IF NOT EXISTS users (
			id INTEGER, github_username TEXT, auth TEXT, role INTEGER, 
			PRIMARY KEY (id))`)

	if err != nil {
		return err
	}

	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS experiments (
			id INTEGER, name TEXT UNIQUE, description TEXT,
			PRIMARY KEY (id))`)

	if err != nil {
		return err
	}

	// TODO: consider a unique constrain to avoid importing identical pairs
	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS file_pairs (
			id INTEGER, name_a TEXT, name_b TEXT, hash_a TEXT, hash_b TEXT,
			content_a TEXT, content_b TEXT, diff TEXT,experiment_id INTEGER,
			PRIMARY KEY (id),
			FOREIGN KEY(experiment_id) REFERENCES experiments(id))`)

	if err != nil {
		return err
	}

	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS assignment (
			user_id INTEGER, pair_id INTEGER, experiment_id INTEGER,
			answer INTEGER, duration INTEGER,
			PRIMARY KEY (user_id, pair_id),
			FOREIGN KEY (user_id) REFERENCES users(id),
			FOREIGN KEY (pair_id) REFERENCES file_pairs(id),
			FOREIGN KEY (experiment_id) REFERENCES experiments(id))`)

	if err != nil {
		return err
	}

	return nil
}

// importFiles imports pairs of files from the origin to the destination DB.
// It copies the contents and processes the needed data (md5 hash, diff)
func importFiles(originDB, destDB *sql.DB) (nFiles int64, err error) {
	// TODO: consider using transaction for increased speed
	rows, err := originDB.Query("SELECT * FROM files;")
	if err != nil {
		return 0, err
	}

	insert, err := destDB.Prepare(`INSERT INTO file_pairs
		(name_a, name_b, hash_a, hash_b, content_a, content_b, diff, experiment_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8);`)

	if err != nil {
		return 0, err
	}

	for rows.Next() {
		var nameA, nameB, contentA, contentB string
		if err := rows.Scan(&nameA, &nameB, &contentA, &contentB); err != nil {
			log.Fatal(err)
		}

		res, err := insert.Exec(nameA, nameB,
			md5hash(contentA), md5hash(contentB),
			contentA, contentB,
			diff(contentA, contentB),
			2) // TODO: set a valid experiment_id

		if err != nil {
			log.Println(err)
			continue
		}

		rowsAffected, _ := res.RowsAffected()
		nFiles += rowsAffected
	}

	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}

	return
}

func md5hash(text string) string {
	return fmt.Sprintf("%x", md5.Sum([]byte(text)))
}

// tmpWrite creates a temporary file and writes the given text in it
func tmpWrite(text string) (*os.File, error) {
	tmpfile, err := ioutil.TempFile("", "annotation-import-tool")
	if err != nil {
		return nil, err
	}

	if _, err := tmpfile.Write([]byte(text)); err != nil {
		return nil, err
	}
	if err := tmpfile.Close(); err != nil {
		return nil, err
	}

	return tmpfile, nil
}

// diff returns the unified diff for the two given input strings
func diff(textA, textB string) string {
	tmpfileA, err := tmpWrite(textA)
	defer os.Remove(tmpfileA.Name())

	if err != nil {
		log.Fatal(err)
	}

	tmpfileB, err := tmpWrite(textB)
	defer os.Remove(tmpfileB.Name())

	if err != nil {
		log.Fatal(err)
	}

	cmd := exec.Command("diff", "-u", tmpfileA.Name(), tmpfileB.Name())
	output, err := cmd.Output()

	// TODO: check error code. Exit code 1 is not an error, it means different files
	/*
		if err != nil {
			log.Fatal(err)
		}
	*/

	return string(output)
}
