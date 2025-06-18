package main

import (
	"chillspot-backend/internal/db"
	"chillspot-backend/internal/middleware"
	"chillspot-backend/internal/models"
	"chillspot-backend/internal/routes"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
)

func main() {
	database := db.ConnectDB()

	if err := database.Exec("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\"").Error; err != nil {
		log.Fatal("Failed to create pgcrypto extension:", err)
	}

	err := database.AutoMigrate(
		&models.User{},
		&models.Spot{},
		&models.Review{},
		&models.Badge{},
	)
	if err != nil {
		log.Fatal("Migration failed:", err)
	}

	err = godotenv.Load()
	if err != nil {
		log.Println("Warning: No .env file found - using default environment variables")
	}

	r := routes.SetupRoutes(database)

	// Get absolute path to uploads directory - FIXED PATH
	wd, _ := os.Getwd()

	// Go up one directory level to get out of the internal folder
	projectRoot := filepath.Dir(wd)

	// Correct path to uploads directory
	uploadsPath := filepath.Join(projectRoot, "internal", "uploads")

	log.Printf("Current working directory: %s", wd)
	log.Printf("Project root: %s", projectRoot)
	log.Printf("Uploads directory: %s", uploadsPath)

	// Create uploads directory if it doesn't exist
	if _, err := os.Stat(uploadsPath); os.IsNotExist(err) {
		if err := os.MkdirAll(uploadsPath, 0755); err != nil {
			log.Fatalf("Failed to create uploads directory: %v", err)
		}
	}

	// Serve static files
	staticHandler := http.StripPrefix("/uploads/", http.FileServer(http.Dir(uploadsPath)))
	r.PathPrefix("/uploads/").Handler(middleware.CorsMiddleware(staticHandler))

	log.Println("Server is running on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
