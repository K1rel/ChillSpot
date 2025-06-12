package routes

import (
	"chillspot-backend/internal/handlers"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

func SetupRoutes(db *gorm.DB) *mux.Router {
	r := mux.NewRouter()

	r.HandleFunc("/register", handlers.Register(db)).Methods("POST")
	r.HandleFunc("/login", handlers.Login(db)).Methods("POST")
	r.HandleFunc("/spots", handlers.AddSpotHandler(db)).Methods("POST")

	return r
}
