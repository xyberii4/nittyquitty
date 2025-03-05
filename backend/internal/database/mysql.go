package database

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
	"github.com/nittyquitty/internal/config"
)

type MySQLClient struct {
	client *sql.DB
}

// Creates User table if it does not exist
func createTable(db *sql.DB) error {
	query := `
    CREATE TABLE IF NOT EXISTS Users (
        UserID INT NOT NULL AUTO_INCREMENT,
        Username VARCHAR(64) NOT NULL,
        Password VARCHAR(64) NOT NULL,
        Snus TINYINT(1) NOT NULL,
        SnusWeeklyUsage INT NOT NULL,
        SnusStrength INT NOT NULL,
        Vape TINYINT(1) NOT NULL,
        VapeWeeklyUsage INT NOT NULL,
        VapeStrength INT NOT NULL,
        Cigarettes TINYINT(1) NOT NULL,
        CigWeeklyUsage INT NOT NULL,
        PRIMARY KEY (UserID)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    `
	_, err := db.Exec(query)
	if err != nil {
		return fmt.Errorf("failed to create table: %w", err)
	}

	return nil
}

// Creates a new MySQL client
func NewMySQLClient(cfg config.MySQLConfig) (*MySQLClient, error) {
	sql_connection := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", cfg.Username, cfg.Password, cfg.Host, cfg.Port, cfg.Database)
	// Connect to database
	database, err := sql.Open("mysql", sql_connection)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to MySQL: %w", err)
	}

	// Check connection
	if err := database.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping MySQL: %w", err)
	}

	// Create the Users table
	if err := createTable(database); err != nil {
		return nil, fmt.Errorf("failed to create table: %w", err)
	}

	return &MySQLClient{
		client: database,
	}, nil
}

// Closes the MySQL client
func (c *MySQLClient) Close() error {
	if err := c.client.Close(); err != nil {
		return fmt.Errorf("failed to close MySQL client: %w", err)
	}
	return nil
}
