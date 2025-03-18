package database

import (
	"testing"

	"github.com/nittyquitty/internal/models"
)

func TestAddUser(t *testing.T) {
	testUser := models.UserData{
		Username: "h",
		Password: "abcd",
	}

	if err := mysqlClient.AddUser(testUser); err != nil {
		t.Errorf("Failed to add user to MySQL: %v", err)
	}
}

func TestGetUser(t *testing.T) {
	userId := 1
	if _, err := mysqlClient.GetUser(userId); err != nil {
		t.Errorf("Failed to get user from MySQL: %v", err)
	}
}
