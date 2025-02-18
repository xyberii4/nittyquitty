package utils

import (
	"os"
	"path/filepath"
	"testing"
)

func TestInitLogger(t *testing.T) {
	logDir := "../../logs/"
	testFn := "test.log"
	testFile := filepath.Join(logDir, testFn)

	// Remove test file after test
	defer func() {
		if err := os.Remove(testFile); err != nil {
			t.Errorf("Failed to remove test log file: %v", err)
		}
	}()

	// Create logger and check it exists
	InitLogger(testFn)
	if _, err := os.Stat(testFile); os.IsNotExist(err) {
		t.Errorf("Failed to create log file: %v", err)
	}
}
