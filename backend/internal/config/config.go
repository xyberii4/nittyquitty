package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
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

// Load env variables
func Load() (*Config, error) {
	if err := godotenv.Load(); err != nil {
		return nil, fmt.Errorf("Error loading .env file: %v", err)
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

	return &Config{
		InfluxDB: inflxCfg,
		MySQL:    mysqlCfg,
	}, nil
}
