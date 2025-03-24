package handlers

import (
	"encoding/json"
	"errors"
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

	utils.Logger.Printf("Consumption data for user %d logged.", usageRow.UserID)
}

// Add new user to MySQL
func (h *Handler) AddUser(w http.ResponseWriter, r *http.Request) {
	utils.Logger.Println("/user/addUser endpoint hit")
	w.Header().Set("Content-Type", "application/json")

	// Check if request body matches expected struct
	var user models.UserData
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, "Invalid JSON body", http.StatusBadRequest)
		return
	}

	// Validate required fields
	if user.Username == "" || user.Password == "" || user.Goal < 0 || user.GoalDeadline == "" {
		http.Error(w, "Missing fields", http.StatusBadRequest)
		return
	}

	// Validate weekly usage and strength for selected products
	if user.Snus && (user.SnusWeeklyUsage <= 0 || user.SnusStrength <= 0) {
		http.Error(w, "Invalid snus usage data", http.StatusBadRequest)
		return
	}
	if user.Vape && (user.VapeWeeklyUsage <= 0 || user.VapeStrength <= 0) {
		http.Error(w, "Invalid vape usage data", http.StatusBadRequest)
		return
	}
	if user.Cigarette && user.CigWeeklyUsage <= 0 {
		http.Error(w, "Invalid cigarette usage data", http.StatusBadRequest)
		return
	}

	// Write to MySQL
	if err := h.MySQLClient.AddUser(user); err != nil {
		http.Error(w, "Failed to write data to MySQL", http.StatusInternalServerError)
		utils.Logger.Printf("Failed to write data to MySQL: %v", err)
		return
	}

	utils.Logger.Printf("Data written to MySQL: New user: %s", user.Username)
	w.WriteHeader(http.StatusOK)
}

func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
	utils.Logger.Println("/user/login endpoint hit")
	w.Header().Set("Content-Type", "application/json")

	// Map request body to struct
	var userRequest models.UserData
	if err := json.NewDecoder(r.Body).Decode(&userRequest); err != nil {
		http.Error(w, "Invalid JSON body", http.StatusBadRequest)
		return
	}

	user, err := h.MySQLClient.AuthenticateUser(userRequest)
	if err != nil {
		// If username or passwird is invalid, return 401
		if errors.Is(err, database.ErrInvalidUser) {
			utils.Logger.Printf("Login failed: %v", err)
			http.Error(w, "Invalid username or password", http.StatusUnauthorized)
			return
		}
		utils.Logger.Printf("Failed to authenticate user %s: %v", user.Username, err)
		http.Error(w, "Failed to authenticate user", http.StatusInternalServerError)
		return
	}

	response, _ := json.Marshal(user)
	w.WriteHeader(http.StatusOK)
	w.Write(response)

	utils.Logger.Printf("User %s authenticated", user.Username)
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
