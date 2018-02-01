package repository

import (
	"database/sql"
	"fmt"

	"github.com/src-d/code-annotation/server/model"
)

// Users repository
type Users struct {
	db *sql.DB
}

// NewUsers returns a new Users repository
func NewUsers(db *sql.DB) *Users {
	return &Users{db: db}
}

// Create stores a User into the DB, and returns that new User
func (repo *Users) Create(user *model.User) error {

	_, err := repo.db.Exec(
		"INSERT INTO users (login, username, avatar_url, role) VALUES ($1, $2, $3, $4)",
		user.Login, user.Username, user.AvatarURL, user.Role)

	if err != nil {
		return err
	}

	user, err = repo.Get(user.Login)
	return err
}

// getWithQuery builds a User from the given sql QueryRow. If the User does not
// exist, it returns nil, nil
func (repo *Users) getWithQuery(queryRow *sql.Row) (*model.User, error) {
	var user model.User

	err := queryRow.Scan(&user.ID, &user.Login, &user.Username, &user.AvatarURL, &user.Role)

	switch {
	case err == sql.ErrNoRows:
		return nil, nil
	case err != nil:
		return nil, fmt.Errorf("Error getting user from the DB: %v", err)
	default:
		return &user, nil
	}
}

// Get returns the User with the given GitHub login name. If the User does not
// exist, it returns nil, nil
func (repo *Users) Get(login string) (*model.User, error) {
	// TODO: escape login string
	return repo.getWithQuery(
		repo.db.QueryRow("SELECT * FROM users WHERE login=$1", login))
}

// GetByID returns the User with the given ID. If the User does not
// exist, it returns nil, nil
func (repo *Users) GetByID(id int) (*model.User, error) {
	return repo.getWithQuery(
		repo.db.QueryRow("SELECT * FROM users WHERE id=$1", id))
}
