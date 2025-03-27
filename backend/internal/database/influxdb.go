package database

import (
	"context"
	"fmt"
	"time"

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
		return nil, fmt.Errorf("failed to check InflixDB health: %v", err)
	}

	if health.Status != "pass" {
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
	utils.Logger.Println("InfluxDB client closed")
}

// Writes nicotine consumption data to InfluxDB
func (c *InfluxdbClient) WriteData(n models.NicotineConsumption) error {
	writeAPI := c.client.WriteAPIBlocking(c.org, c.bucket)

	// Convert to InfluxDB point
	point := n.ToInfluxPoint()

	if err := writeAPI.WritePoint(context.Background(), point); err != nil {
		return fmt.Errorf("failed to write data to InfluxDB: %v", err)
	}

	return nil
}

// Query data for given user, start and stop must be in RFC3339 format (YYYY-MM-DDTHH:MM:SSZ)
func (c *InfluxdbClient) GetUserData(user models.UserData, start, end string) ([]models.NicotineConsumption, error) {
	queryAPI := c.client.QueryAPI(c.org)
	query := fmt.Sprintf(`
    from(bucket: "%s")
    |> range(start: %s, stop: %s)
    |> filter(fn: (r) => r.user_id == "%d")
    `, c.bucket, start, end, user.UserID)

	result, err := queryAPI.Query(context.Background(), query)
	if err != nil {
		return nil, fmt.Errorf("failed to query InfluxDB: %v", err)
	}

	// Maps fields with same timestamp to a single row
	rowsMap := make(map[time.Time]*models.NicotineConsumption)

	for result.Next() {
		record := result.Record()
		ts := record.Time()

		if _, e := rowsMap[ts]; !e {
			rowsMap[ts] = &models.NicotineConsumption{
				UserID:    user.UserID,
				Timestamp: ts.Format("2006-01-02T15:04:05Z"),
				Product:   record.ValueByKey("product").(string),
			}
		}

		row := rowsMap[ts]

		// Add all fields to row stuct
		switch record.Field() {
		case "mg":
			row.Mg = record.Value().(float64)
		case "quantity":
			row.Quantity = int(record.Value().(int64))
		case "cost":
			row.Cost = record.Value().(float64)
		}

	}

	// Convert map to slice
	var rows []models.NicotineConsumption
	for _, v := range rowsMap {
		rows = append(rows, *v)
	}

	return rows, nil
}
