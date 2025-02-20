package database

import (
	"os"
	"testing"

	"github.com/joho/godotenv"
	"github.com/nittyquitty/internal/config"
)

func TestNewClient(t *testing.T) {
	if err := godotenv.Load("../../.env"); err != nil {
		t.Errorf("Error loading .env file: %v", err)
	}
	cfg := config.InfluxDBConfig{
		Url:   os.Getenv("INFLUX_URL"),
		Token: os.Getenv("INFLUX_TOKEN"),
		Port:  os.Getenv("INFLUX_PORT"),
	}
	c, err := NewClient(cfg)

	defer func() {
		c.client.Close()
	}()

	if err != nil {
		t.Errorf("Failed to create InfluxDB client: %v", err)
	}
}
