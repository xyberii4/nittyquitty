package database

import (
	"testing"

	"github.com/nittyquitty/internal/models"
)

// Writes test data to InfluxDB
func TestInfluxDBWrite(t *testing.T) {
	testdata := models.NicotineConsumption{
		UserID:    -1,
		Product:   "test",
		Mg:        1.0,
		Quantity:  10,
		Cost:      1.0,
		Timestamp: "2025-03-25T15:00:00Z",
	}

	if err := influxdbClient.WriteData(testdata); err != nil {
		t.Errorf("Failed to write data to InfluxDB: %v", err)
	} else {
		t.Logf("Successfully wrote data to InfluxDB")
	}
}

func TestInfluxDBQuery(t *testing.T) {
	start := "2023-10-10"
	stop := "2025-03-06"
	user := models.UserData{
		UserID: 123,
	}
	_, err := influxdbClient.GetUserData(user, start, stop)
	if err != nil {
		t.Errorf("Failed to query data from InfluxDB: %v", err)
	}
}
