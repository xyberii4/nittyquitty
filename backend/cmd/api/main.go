package main

import (
	"github.com/nittyquitty/internal/utils"
)

func main() {
	// Create logger
	utils.InitLogger("api.log")
	defer utils.Logger.Println("API stopped")
}
