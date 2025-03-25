package database

import (
	"testing"

	"github.com/nittyquitty/internal/models"
)

func TestAddUser(t *testing.T) {
	testUser := models.UserData{
		Username:     "mysql_test",
		Password:     "abcd",
		Goal:         1,
		GoalDeadline: "2024-10-31",
	}

	if err := mysqlClient.AddUser(testUser); err != nil {
		t.Errorf("Failed to add user to MySQL: %v", err)
	} else {
		t.Logf("Added new user %s", testUser.Username)
	}
}

func TestDeleteUser(t *testing.T) {
	query := "Select UserID from Users where Username = ?"
	testUser := models.UserData{
		Username: "mysql_test",
		Password: "abcd",
	}

	if err := mysqlClient.client.QueryRow(query, "mysql_test").Scan(&testUser.UserID); err != nil {
		t.Errorf("Failed to find user in MySQL: %v", err)
	}

	if err := mysqlClient.DeleteUser(testUser); err != nil {
		t.Errorf("Failed to delete user from MySQL: %v", err)
	} else {
		t.Logf("Deleted user %s", testUser.Username)
	}
}
