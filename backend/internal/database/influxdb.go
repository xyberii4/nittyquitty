package database

import (
	"context"
	"fmt"

	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/nittyquitty/internal/config"
	"github.com/nittyquitty/internal/models"
	"github.com/nittyquitty/internal/utils"
)

type InfluxdbClient struct {
	client influxdb2.Client
	org    string
	bucket string
}

// Creates a new InfluxDB client
func NewInfluxDBClient(cfg config.InfluxDBConfig) (*InfluxdbClient, error) {
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

	return &InfluxdbClient{
		client: client,
		org:    cfg.Org,
		bucket: cfg.Bucket,
	}, nil
}

// Closes the InfluxDB client
func (c *InfluxdbClient) Close() {
	c.client.Close()
}

// Writes nicotine consumption data to InfluxDB
func (c *InfluxdbClient) WriteData(n models.NicotineConsumption) error {
	writeAPI := c.client.WriteAPIBlocking(c.org, c.bucket)

	// Convert to InfluxDB point
	point := n.ToInfluxPoint()

	if err := writeAPI.WritePoint(context.Background(), point); err != nil {
		utils.Logger.Printf("Failed to write data to InfluxDB: %v", err)
		return fmt.Errorf("failed to write data to InfluxDB: %v", err)
	}

	utils.Logger.Printf("Data written to InfluxDB: %v", n)
	return nil
}
