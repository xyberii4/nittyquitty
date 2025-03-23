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

	// Define the start and end dates
	endDate := time.Now()
	startDate := endDate.AddDate(0, -3, 0) // Subtract 3 months from the current date

	// Loop through each day for 3 months
	for date := startDate; date.Before(endDate); date = date.AddDate(0, 0, 1) {
		// Generate random data for each day
		testData := models.NicotineConsumption{
			UserID:    123,
			Product:   "vapes",
			Mg:        1 + r.Float64()*49,
			Quantity:  r.Intn(10) + 1,
			Cost:      0.5 + r.Float64()*19.5,
			Timestamp: date,
		}

		// Write data to InfluxDB
		if err := influxdbClient.WriteData(testData); err != nil {
			t.Errorf("Failed to write data for date %v to InfluxDB: %v", date, err)
		}
	}

	t.Logf("Successfully populated InfluxDB with 3 months of fake data")
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
