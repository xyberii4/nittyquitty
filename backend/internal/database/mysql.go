package database

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
	"github.com/nittyquitty/internal/config"
	"github.com/nittyquitty/internal/models"
	"github.com/nittyquitty/internal/utils"
)

type MySQLClient struct {
	client *sql.DB
}

// Create User table if it does not exist
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
        Cigarette TINYINT(1) NOT NULL,
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

// Create a new MySQL client
func NewMySQLClient(cfg config.MySQLConfig) (*MySQLClient, error) {
	sql_connection := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", cfg.Username, cfg.Password, cfg.Host, cfg.Port, cfg.Database)
	// Conn to database
	database, err := sql.Open("mysql", sql_connection)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to MySQL: %w", err)
	}

	// Check conn
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

// Close the MySQL client
func (c *MySQLClient) Close() {
	c.client.Close()
	utils.Logger.Println("MySQL client closed")
}

// Add user to MySQL
func (c *MySQLClient) AddUser(n models.UserData) error {
	// Check for duplicate username
	var existingUserID int
	err := c.client.QueryRow("SELECT UserID FROM Users WHERE Username = ?", n.Username).Scan(&existingUserID)
	if err != nil && err != sql.ErrNoRows {
		utils.Logger.Printf("Failed to check for duplicate username: %v", err)
		return fmt.Errorf("failed to check for duplicate username: %v", err)
	}
	if existingUserID != 0 {
		utils.Logger.Printf("Username already exists: %s", n.Username)
		return fmt.Errorf("username already exists: %s", n.Username)
	}

	// Prepare the INSERT statement
	query := `
		INSERT INTO Users 
		(Username, Password, Snus, SnusWeeklyUsage, SnusStrength, Vape, VapeWeeklyUsage, VapeStrength, Cigarette, CigWeeklyUsage) 
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`
	stmt, err := c.client.Prepare(query)
	if err != nil {
		utils.Logger.Printf("Failed to prepare statement: %v", err)
		return fmt.Errorf("failed to prepare statement: %v", err)
	}
	defer stmt.Close()

	// Execute the statement with user data
	_, err = stmt.Exec(
		n.Username,
		n.Password,
		n.Snus,
		n.SnusWeeklyUsage,
		n.SnusStrength,
		n.Vape,
		n.VapeWeeklyUsage,
		n.VapeStrength,
		n.Cigarette,
		n.CigWeeklyUsage,
	)
	if err != nil {
		utils.Logger.Printf("Failed to execute statement: %v", err)
		return fmt.Errorf("failed to execute statement: %v", err)
	}

	utils.Logger.Printf("User added to MySQL: %v", n)
	return nil
}

// Retrieves user from MySQL
func (c *MySQLClient) GetUser(userID int) (models.UserData, error) {
	// Prepare the SELECT statement
	query := "SELECT * FROM Users WHERE UserID = ?"
	stmt, err := c.client.Prepare(query)
	if err != nil {
		utils.Logger.Printf("Failed to prepare statement: %v", err)
		return models.UserData{}, fmt.Errorf("failed to prepare statement: %v", err)
	}
	defer stmt.Close()

	// Execute the query and scan the result into the UserData struct
	var user models.UserData
	err = stmt.QueryRow(userID).Scan(
		&user.UserID,
		&user.Username,
		&user.Password,
		&user.Snus,
		&user.SnusWeeklyUsage,
		&user.SnusStrength,
		&user.Vape,
		&user.VapeWeeklyUsage,
		&user.VapeStrength,
		&user.Cigarette,
		&user.CigWeeklyUsage,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			utils.Logger.Printf("User not found: %d", userID)
			return models.UserData{}, fmt.Errorf("user not found: %d", userID)
		}
		utils.Logger.Printf("Failed to execute statement: %v", err)
		return models.UserData{}, fmt.Errorf("failed to execute statement: %v", err)
	}

	utils.Logger.Printf("User retrieved from MySQL: %v", user)
	return user, nil
}
