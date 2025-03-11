package database

import (
	"math/rand"
	"testing"
	"time"

	"github.com/nittyquitty/internal/models"
)

// Writes test data to InfluxDB
func TestInfluxDBWrite(t *testing.T) {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	testData := models.NicotineConsumption{
		UserID:   123,
		Product:  "test",
		Mg:       r.Float64(),
		Quantity: r.Intn(10),
		Cost:     r.Float64(),
	}

	if err := influxdbClient.WriteData(testData); err != nil {
		t.Errorf("Failed to write data to InfluxDB: %v", err)
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
