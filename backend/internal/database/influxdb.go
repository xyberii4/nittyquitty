package database

import (
	"context"
	"fmt"

	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/nittyquitty/internal/config"
	"github.com/nittyquitty/internal/utils"
)

type Client struct {
	client influxdb2.Client
	org    string
	bucket string
}

func NewClient(cfg config.InfluxDBConfig) (*Client, error) {
	client := influxdb2.NewClient(fmt.Sprintf("%s:%s", cfg.Url, cfg.Port), cfg.Token)

	// Check client health
	health, err := client.Health(context.Background())
	if err != nil {
		utils.Logger.Printf("Failed to check InflixDB health: %v", err)
		return nil, fmt.Errorf("failed to check InflixDB health: %v", err)
	}

	if health.Status != "pass" {
		utils.Logger.Printf("InfluxDB health check failed: %v", health)
		return nil, fmt.Errorf("influxDB health check failed: %v", health)
	}

	return &Client{
		client: client,
		org:    cfg.Org,
		bucket: cfg.Bucket,
	}, nil
}
