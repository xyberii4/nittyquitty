package utils

import (
	"log"
	"os"
	"path/filepath"
)

var (
	Logger *log.Logger
	logDir string
)

func InitLogger(fn string) {
	// Ensure logs are created in project root
	targetDir := "internal"
	dir, err := os.Getwd()
	if err != nil {
		log.Fatalf("Failed to get working directory: %v", err)
	}

	for {
		if _, err := os.Stat(filepath.Join(dir, targetDir)); err == nil {
			logDir = filepath.Join(dir, "logs")
			break
		}
		dir = filepath.Dir(dir)
	}

	// Ensure log directory exists
	if err := os.MkdirAll(logDir, 0755); err != nil {
		log.Fatalf("Failed to create log directory: %v", err)
	}

	// Ensure log file exists
	logFile, err := os.OpenFile(filepath.Join(logDir, fn), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		log.Fatalf("Failed to open log file: %v", err)
	}

	// Create a new logger in format: API: <date> <time> <file>:<line_no>: <message>
	Logger = log.New(logFile, "API: ", log.Ldate|log.Ltime|log.Lshortfile)
}
