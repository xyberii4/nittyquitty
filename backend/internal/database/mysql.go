package database

import (
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
	"github.com/nittyquitty/internal/config"
	"github.com/nittyquitty/internal/models"
	"github.com/nittyquitty/internal/utils"
)

type MySQLClient struct {
	client *sql.DB
}

var ErrInvalidUser = errors.New("invalid user")

// Create User table if it does not exist
func createTable(db *sql.DB) error {
	query := `
    CREATE TABLE IF NOT EXISTS Users (
        UserID INT NOT NULL AUTO_INCREMENT,
        Username VARCHAR(64) NOT NULL,
        Password VARCHAR(64) NOT NULL,
        Snus TINYINT(1) NOT NULL,
        SnusWeeklyUsage INT NOT NULL,
        SnusStrength DECIMAL(5,2) NOT NULL,
        Vape TINYINT(1) NOT NULL,
        VapeWeeklyUsage INT NOT NULL,
        VapeStrength DECIMAL(5,2) NOT NULL,
        Cigarette TINYINT(1) NOT NULL,
        CigWeeklyUsage INT NOT NULL,
        Goal INT NOT NULL,
        GoalDeadline DATE NOT NULL,
        WeeklySpending DECIMAL(5,2) NOT NULL,
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
	var existingUsername int
	err := c.client.QueryRow("SELECT UserID FROM Users WHERE Username = ?", n.Username).Scan(&existingUsername)
	if err != nil && err != sql.ErrNoRows {
		return fmt.Errorf("failed to check for duplicate username: %v", err)
	}
	if existingUsername != 0 {
		return fmt.Errorf("username already exists: %s", n.Username)
	}

	hasher := sha256.New()
	hasher.Write([]byte(n.Password))
	hashedPassword := hex.EncodeToString(hasher.Sum(nil))

	// Prepare the INSERT statement
	query := `
		INSERT INTO Users 
		(Username, Password, Snus, SnusWeeklyUsage, SnusStrength, Vape, VapeWeeklyUsage, VapeStrength, Cigarette, CigWeeklyUsage, Goal, GoalDeadline, WeeklySpending)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`
	stmt, err := c.client.Prepare(query)
	if err != nil {
		return fmt.Errorf("failed to prepare statement: %v", err)
	}
	defer stmt.Close()

	// Execute the statement with user data
	_, err = stmt.Exec(
		n.Username,
		hashedPassword,
		n.Snus,
		n.SnusWeeklyUsage,
		n.SnusStrength,
		n.Vape,
		n.VapeWeeklyUsage,
		n.VapeStrength,
		n.Cigarette,
		n.CigWeeklyUsage,
		n.Goal,
		n.GoalDeadline,
		n.WeeklySpending,
	)
	if err != nil {
		return fmt.Errorf("failed to execute statement: %v", err)
	}

	return nil
}

// Authenticate user and return user data
func (c *MySQLClient) AuthenticateUser(user models.UserData) (models.UserData, error) {
	// Hash password
	hasher := sha256.New()
	hasher.Write([]byte(user.Password))
	hashedPassword := hex.EncodeToString(hasher.Sum(nil))

	// Prepare query
	query := "SELECT * FROM Users WHERE Username = ? AND Password = ?"
	stmt, err := c.client.Prepare(query)
	if err != nil {
		return models.UserData{}, fmt.Errorf("failed to prepare statement: %w", err)
	}

	defer stmt.Close()

	// Returns all user data to be stored in the session
	err = stmt.QueryRow(user.Username, hashedPassword).Scan(
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
		&user.Goal,
		&user.GoalDeadline,
		&user.WeeklySpending,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return models.UserData{}, ErrInvalidUser
		}
		return models.UserData{}, fmt.Errorf("failed to execute statement: %w", err)
	}
	user.Password = ""
	return user, nil
}

func (c *MySQLClient) DeleteUser(user models.UserData) error {
	// Hash password
	hasher := sha256.New()
	hasher.Write([]byte(user.Password))
	hashedPassword := hex.EncodeToString(hasher.Sum(nil))

	// Prepare query
	query := "DELETE FROM Users WHERE UserID = ? AND Password = ?"
	stmt, err := c.client.Prepare(query)
	if err != nil {
		return fmt.Errorf("failed to prepare statement: %w", err)
	}

	defer stmt.Close()

	res, err := stmt.Exec(user.UserID, hashedPassword)
	if err != nil {
		return fmt.Errorf("failed to execute statement: %w", err)
	}

	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("failed to delete user: %w", ErrInvalidUser)
	}

	return nil
}
