package database

import (
	"os"
	"testing"

	"github.com/joho/godotenv"
	"github.com/nittyquitty/internal/config"
)

func TestNewMySQLClient(t *testing.T) {
	if err := godotenv.Load("../../.env"); err != nil {
		t.Errorf("Error loading .env file: %v", err)
	}

	cfg := config.MySQLConfig{
		Host:     os.Getenv("MYSQL_HOST"),
		Port:     os.Getenv("MYSQL_PORT"),
		Username: os.Getenv("MYSQL_USERNAME"),
		Password: os.Getenv("MYSQL_PASSWORD"),
		Database: os.Getenv("MYSQL_DATABASE"),
	}

	c, err := NewMySQLClient(cfg)

	defer func() {
		c.Close()
	}()

	if err != nil {
		t.Errorf("Failed to create MySQL client: %v", err)
	}
}
