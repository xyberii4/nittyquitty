package config

import (
	"os"

	"github.com/joho/godotenv"
	"github.com/nittyquitty/internal/utils"
)

type InfluxDBConfig struct {
	Url    string
	Port   string
	Token  string
	Org    string
	Bucket string
}

type MySQLConfig struct {
	Host     string
	Port     string
	Username string
	Password string
	Database string
}

type Config struct {
	InfluxDB InfluxDBConfig
	MySQL    MySQLConfig
}

func Load() Config {
	if err := godotenv.Load(); err != nil {
		utils.Logger.Fatalf("Error loading .env file: %v", err)
	}

	inflxCfg := InfluxDBConfig{
		Url:    os.Getenv("INFLUX_URL"),
		Port:   os.Getenv("INFLUX_PORT"),
		Token:  os.Getenv("INFLUX_TOKEN"),
		Org:    os.Getenv("INFLUX_ORG"),
		Bucket: os.Getenv("INFLUX_BUCKET"),
	}

	mysqlCfg := MySQLConfig{
		Host:     os.Getenv("MYSQL_HOST"),
		Port:     os.Getenv("MYSQL_PORT"),
		Username: os.Getenv("MYSQL_USERNAME"),
		Password: os.Getenv("MYSQL_PASSWORD"),
		Database: os.Getenv("MYSQL_DATABASE"),
	}

	utils.Logger.Println("Environment variables loaded successfully")

	return Config{
		InfluxDB: inflxCfg,
		MySQL:    mysqlCfg,
	}
}
