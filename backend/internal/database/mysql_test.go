package database

import (
	"testing"

	_ "github.com/go-sql-driver/mysql"
	"github.com/nittyquitty/internal/utils"
)

func (c *MySQLClient) TestInsert(t *testing.T) {
	// Insert data
	_, err := c.client.Exec("INSERT INTO Users (UserID, Username, Password, Snus, SnusWeeklyUsage, SnusStrength, Vape, VapeWeeklyUsage, VapeStrength, Cigarette, CigWeeklyUsage) VALUES ('123', 'Nitty', 'Quitty', True, 14, 6, True, 1, 12, True, 20)")
	if err != nil {
		utils.Logger.Printf("Failed to insert data: %v", err)
	}
}
