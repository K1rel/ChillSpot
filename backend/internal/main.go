package main

import (
	"chillspot-backend/internal/db"
	"chillspot-backend/internal/models"
	"chillspot-backend/internal/routes"

	"log"
	"net/http"
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

	r := routes.SetupRoutes(database)

	log.Println("Server is running on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
