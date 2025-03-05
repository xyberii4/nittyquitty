package models

import (
	"time"

	"github.com/influxdata/influxdb-client-go/v2/api/write"
)

// Struct for each time the user consumes nicotine
type NicotineConsumption struct {
	Product  string  `json:"product"`  // Vape/Cigarette/Snus/etc
	UserID   string  `json:"userID"`   // Same as MySQL
	Mg       float64 `json:"mg"`       // Nicotine amount in mg
	Quantity int     `json:"quantity"` // Quantity consumed
	Cost     float64 `json:"cost"`     // Cost of the product
}

// User struct with JSON tags
type UserData struct {
	UserID          int    `json:"user_id"`
	Username        string `json:"username"`
	Password        string `json:"password"`
	Snus            bool   `json:"snus"`
	SnusWeeklyUsage int    `json:"snus_weekly_usage"`
	SnusStrength    int    `json:"snus_strength"`
	Vape            bool   `json:"vape"`
	VapeWeeklyUsage int    `json:"vape_weekly_usage"`
	VapeStrength    int    `json:"vape_strength"`
	Cigarette       bool   `json:"cigarette"`
	CigWeeklyUsage  int    `json:"cig_weekly_usage"`
}

// Converts NicotineConsumption to InfluxDB point
func (n *NicotineConsumption) ToInfluxPoint() *write.Point {
	return write.NewPoint(
		"nicotine_consumption",
		map[string]string{"product": n.Product, "user_id": n.UserID},
		map[string]interface{}{"mg": n.Mg, "quantity": n.Quantity, "cost": n.Cost},
		time.Now(),
	)
}
