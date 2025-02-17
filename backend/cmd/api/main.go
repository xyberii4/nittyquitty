package main

import (
	"log"
	"net/http"

	"github.com/nittyquitty/internal/routes"
	"github.com/nittyquitty/internal/database"
)

func main() {
	r := routes.SetupRouter()
	log.Println("Starting server on :8080")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatalf("Could not start server: %v\n", err)
	}
	database.insert("nittyquitty", "nitty@quitty.com", "IAMANITTY420")
	database.query(1)
}
