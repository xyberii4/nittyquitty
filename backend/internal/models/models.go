package models

import (
	"strconv"
	"time"

	"github.com/influxdata/influxdb-client-go/v2/api/write"
)

// Struct for each time the user consumes nicotine
type NicotineConsumption struct {
	Product   string    `json:"product"`   // Vape/Cigarette/Snus/etc
	UserID    int       `json:"user_id"`   // Same as MySQL
	Mg        float64   `json:"mg"`        // Nicotine amount in mg
	Quantity  int       `json:"quantity"`  // Quantity consumed
	Cost      float64   `json:"cost"`      // Cost of the product
	Timestamp time.Time `json:"timestamp"` // Time of consumption
}

// ConsumptionRequest struct with JSON tags
type ConsumptionRequest struct {
	UserID    int    `json:"user_id"`
	StartDate string `json:"start_date"`
	EndDate   string `json:"end_date"`
}

// User struct with JSON tags
type UserData struct {
	UserID          int     `json:"user_id"`
	Username        string  `json:"username"`
	Password        string  `json:"password"`
	Snus            bool    `json:"snus"`
	SnusWeeklyUsage int     `json:"snus_weekly_usage"`
	SnusStrength    float64 `json:"snus_strength"`
	Vape            bool    `json:"vape"`
	VapeWeeklyUsage int     `json:"vape_weekly_usage"`
	VapeStrength    float64 `json:"vape_strength"`
	Cigarette       bool    `json:"cigarette"`
	CigWeeklyUsage  int     `json:"cig_weekly_usage"`
	Goal            float64 `json:"goal"`
	GoalDeadline    string  `json:"goal_deadline"`
}

// Converts NicotineConsumption to InfluxDB point
func (n *NicotineConsumption) ToInfluxPoint() *write.Point {
	return write.NewPoint(
		"nicotine_consumption",
		map[string]string{"product": n.Product, "user_id": strconv.Itoa(n.UserID)},
		map[string]interface{}{"mg": n.Mg, "quantity": n.Quantity, "cost": n.Cost},
		time.Now(),
	)
}
