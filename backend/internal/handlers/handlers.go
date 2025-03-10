package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/nittyquitty/internal/database"
	"github.com/nittyquitty/internal/models"
	"github.com/nittyquitty/internal/utils"
)

type Handler struct {
	InfluxDBClient *database.InfluxdbClient
	MySQLClient    *database.MySQLClient
}

// Create handler
func NewHandler(ic *database.InfluxdbClient, mc *database.MySQLClient) *Handler {
	return &Handler{
		InfluxDBClient: ic,
		MySQLClient:    mc,
	}
}

// Check if API is reachable
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"alive": true}`))
}

// Adds users' nicotine usage to InfluxDB
func (h *Handler) LogConsumption(w http.ResponseWriter, r *http.Request) {
	utils.Logger.Println("/api/logUsage endpoint hit")
	w.Header().Set("Content-Type", "application/json")

	// Check if request body matches expected struct
	var usageRow models.NicotineConsumption
	if err := json.NewDecoder(r.Body).Decode(&usageRow); err != nil {
		http.Error(w, "Invalid JSON body", http.StatusBadRequest)
		return
	}

	// Write to InfluxDB
	if err := h.InfluxDBClient.WriteData(usageRow); err != nil {
		http.Error(w, "Failed to write data to InfluxDB", http.StatusInternalServerError)
		utils.Logger.Printf("Failed to write data to InfluxDB: %v", err)
		return
	}

	utils.Logger.Println("Data written to InfluxDB") // include username asw
}

// Add new user to MySQL
func (h *Handler) AddUser(w http.ResponseWriter, r *http.Request) {
	utils.Logger.Println("/api/addUser endpoint hit")
	w.Header().Set("Content-Type", "application/json")

	// Check if request body matches expected struct
	var user models.UserData
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, "Invalid JSON body", http.StatusBadRequest)
		return
	}

	// Write to MySQL
	if err := h.MySQLClient.AddUser(user); err != nil {
		http.Error(w, "Failed to write data to MySQL", http.StatusInternalServerError)
		utils.Logger.Printf("Failed to write data to MySQL: %v", err)
		return
	}

	utils.Logger.Println("Data written to MySQL")
}

// Get user consumption data for given userID
func (h *Handler) GetConsumption(w http.ResponseWriter, r *http.Request) {
	utils.Logger.Println("/api/getUserConsumption endpoint hit")

	// Map request body to struct
	var cRequest models.ConsumptionRequest
	err := json.NewDecoder(r.Body).Decode(&cRequest)
	if err != nil {
		http.Error(w, "Invalid JSON body", http.StatusBadRequest)
		return
	}

	user := models.UserData{
		UserID: int(cRequest.UserID),
	}

	// Retrieve rows from InfluxDB
	results, err := h.InfluxDBClient.GetUserData(user, cRequest.StartDate, cRequest.EndDate)
	if err != nil {
		http.Error(w, "Failed to get data from InfluxDB", http.StatusInternalServerError)
		utils.Logger.Printf("Failed to get data from InfluxDB: %v", err)
		return
	}

	// Map rows to JSON and write to response
	jsonResults, err := json.Marshal(results)
	if err != nil {
		http.Error(w, "Failed to marshal JSON", http.StatusInternalServerError)
		utils.Logger.Printf("Failed to marshal JSON: %v", err)
		return
	}

	w.Write(jsonResults)

	utils.Logger.Printf("Data retrieved from InfluxDB for user: %d", user.UserID)
}
