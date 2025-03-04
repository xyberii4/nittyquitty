package database

import (
	"testing"

	"github.com/nittyquitty/internal/models"
)

// Writes test data to InfluxDB
func TestInfluxDBWrite(t *testing.T) {
	testData := models.NicotineConsumption{
		UserID:   "123",
		Product:  "test",
		Mg:       10,
		Quantity: 1,
		Cost:     1,
	}

	if err := influxdbClient.WriteData(testData); err != nil {
		t.Errorf("Failed to write data to InfluxDB: %v", err)
	}
}
