package routes

import (
	"github.com/go-chi/chi/v5"
	"github.com/nittyquitty/internal/handlers"
)

func SetupRouter() *chi.Mux {
	r := chi.NewRouter()

	r.Get("/", handlers.Test)

	return r
}
