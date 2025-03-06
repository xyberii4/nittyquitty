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

// Creates a new MySQL client
func NewMySQLClient(cfg config.MySQLConfig) (*MySQLClient, error) {
	sql_connection := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", cfg.Username, cfg.Password, cfg.Host, cfg.Port, cfg.Database)
	// Connect to database
	database, err := sql.Open("mysql", sql_connection)
	if err != nil {
		utils.Logger.Printf("Failed to connect to MySQL: %v", err)
		return nil, fmt.Errorf("failed to connect to MySQL: %v", err)
	}

	// Check connection
	if err := database.Ping(); err != nil {
		utils.Logger.Printf("Failed to ping MySQL: %v", err)
		return nil, fmt.Errorf("failed to ping MySQL: %v", err)
	}

	return &MySQLClient{
		client: database,
	}, nil
}

// Closes the MySQL client
func (c *MySQLClient) Close() {
	c.client.Close()
	utils.Logger.Println("MySQL client closed")
}


// Adds user to MySQL
func (c *MySQLClient) AddUser(n models.UserData) error {

	// Prepare statement
	stmt, err := c.client.Prepare(fmt.Sprintf("INSERT INTO Users (UserID, Username, Password, Snus, SnusWeeklyUsage, SnusStrength, Vape, VapeWeeklyUsage, VapeStrength, Cigarette, CigWeeklyUsage) VALUES (%d, %s, %s, %t, %d, %d, %t, %d, %d, %t, %d)", n.UserID, n.Username, n.Password, n.Snus, n.SnusWeeklyUsage, n.SnusStrength, n.Vape, n.VapeWeeklyUsage, n.VapeStrength, n.Cigarette, n.CigWeeklyUsage))
	if err != nil {
		utils.Logger.Printf("Failed to prepare statement: %v", err)
		return fmt.Errorf("failed to prepare statement: %v", err)
	}

	// Execute statement
	if _, err := stmt.Exec(n); err != nil {
		utils.Logger.Printf("Failed to execute statement: %v", err)
		return fmt.Errorf("failed to execute statement: %v", err)
	}

	utils.Logger.Printf("User added to MySQL: %v", n)
	return nil
}


// Retrieves user from MySQL
func (c *MySQLClient) GetUser(userID int) (models.UserData, error) {
	
	// Prepare statement
	stmt, err := c.client.Prepare(fmt.Sprintf("SELECT * FROM Users WHERE UserID = %d", userID))
	if err != nil {
		utils.Logger.Printf("Failed to prepare statement: %v", err)
		return models.UserData{}, fmt.Errorf("failed to prepare statement: %v", err)
	}

	// Execute statement
	var user models.UserData
	if err := stmt.QueryRow(userID).Scan(&user); err != nil {
		utils.Logger.Printf("Failed to execute statement: %v", err)
		return models.UserData{}, fmt.Errorf("failed to execute statement: %v", err)
	}

	utils.Logger.Printf("User retrieved from MySQL: %v", user)
	return user, nil
}