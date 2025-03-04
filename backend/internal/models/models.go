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

type UserData struct {
	UserID          int
	Username        string
	Password        string
	Snus            bool
	SnusWeeklyUsage int
	SnusStrength    int
	Vape            bool
	VapeWeeklyUsage int
	VapeStrength    int
	Cigarette       bool
	CigWeeklyUsage  int
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
