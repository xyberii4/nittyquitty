package database

import (
	"testing"

	"github.com/nittyquitty/internal/models"
)

func TestAddUser(t *testing.T) {
	testUser := models.UserData{
		Username:     "h",
		Password:     "abcd",
		Goal:         1,
		GoalDeadline: "2024-10-31",
	}

	if err := mysqlClient.AddUser(testUser); err != nil {
		t.Errorf("Failed to add user to MySQL: %v", err)
	}
}
