package database

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
	"github.com/nittyquitty/internal/config"
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
