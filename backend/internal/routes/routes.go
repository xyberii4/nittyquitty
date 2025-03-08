package routes

import (
	"github.com/go-chi/chi/v5"
	"github.com/nittyquitty/internal/database"
	"github.com/nittyquitty/internal/handlers"
)

func Setup(ic *database.InfluxdbClient, mc *database.MySQLClient) chi.Router {
	handler := handlers.NewHandler(ic, mc)

	r := chi.NewRouter()

	r.Get("/api/health", handler.HealthCheck)
	r.Post("/api/logUsage", handler.LogNicUsage)
	r.Get("api/getConsumption", handler.GetUserConsumption)
	return r
}
