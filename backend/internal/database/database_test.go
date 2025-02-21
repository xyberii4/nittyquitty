package database

import (
	"os"
	"testing"

	"github.com/joho/godotenv"
	"github.com/nittyquitty/internal/config"
	"github.com/nittyquitty/internal/utils"
)

var (
	influxdbClient *InfluxdbClient
	mysqlClient    *MySQLClient
)

// Test entry point
func TestMain(m *testing.M) {
	utils.InitLogger("test.log")

	if err := godotenv.Load("../../.env"); err != nil {
		utils.Logger.Fatalf("Error loading .env file: %v", err)
	}

	// Create InflixDB client
	influxdbcfg := config.InfluxDBConfig{
		Url:    os.Getenv("INFLUX_URL"),
		Token:  os.Getenv("INFLUX_TOKEN"),
		Port:   os.Getenv("INFLUX_PORT"),
		Org:    os.Getenv("INFLUX_ORG"),
		Bucket: os.Getenv("INFLUX_BUCKET"),
	}
	var err error
	influxdbClient, err = NewInfluxDBClient(influxdbcfg)
	if err != nil {
		utils.Logger.Fatalf("Failed to create InfluxDB client: %v", err)
	}

	// Create MySQL client
	mysqlcfg := config.MySQLConfig{
		Host:     os.Getenv("MYSQL_HOST"),
		Port:     os.Getenv("MYSQL_PORT"),
		Username: os.Getenv("MYSQL_USERNAME"),
		Password: os.Getenv("MYSQL_PASSWORD"),
		Database: os.Getenv("MYSQL_DATABASE"),
	}

	mysqlClient, err = NewMySQLClient(mysqlcfg)
	if err != nil {
		utils.Logger.Fatalf("Failed to create MySQL client: %v", err)
	}

	// Run all tests
	code := m.Run()

	influxdbClient.Close()
	mysqlClient.Close()

	os.Exit(code)
}
