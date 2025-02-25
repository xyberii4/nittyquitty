package main

import (
	"github.com/nittyquitty/internal/config"
	"github.com/nittyquitty/internal/database"
	"github.com/nittyquitty/internal/utils"
)

func main() {
	// Create logger
	utils.InitLogger("api.log")
	defer utils.Logger.Println("API stopped")

	// Load config
	cfg, err := config.Load()
	if err != nil {
		utils.Logger.Fatalf("Error loading config: %v", err)
	}
	utils.Logger.Println("Config loaded successfully")

	// Initialize InfluxDB client
	InfluxDBClient, err := database.NewInfluxDBClient(cfg.InfluxDB)
	if err != nil {
		utils.Logger.Fatalf("Failed to connect to InfluxDB: %v", err)
	}
	defer InfluxDBClient.Close()

	utils.Logger.Println("InfluxDB client initialized successfully")

	// Initialize MySQL client
	MySQLClient, err := database.NewMySQLClient(cfg.MySQL)
	if err != nil {
		utils.Logger.Fatalf("Failed to connect to MySQL: %v", err)
	}
	defer MySQLClient.Close()

	utils.Logger.Println("MySQL client initialized successfully")
}
