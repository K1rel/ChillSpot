package routes

import (
	"chillspot-backend/internal/handlers"
	"chillspot-backend/internal/middleware"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

func SetupRoutes(db *gorm.DB) *mux.Router {
	r := mux.NewRouter()
	r.Use(middleware.CorsMiddleware)
	r.HandleFunc("/register", handlers.Register(db)).Methods("POST")
	r.HandleFunc("/login", handlers.Login(db)).Methods("POST")

	// Protected routes
	protected := r.PathPrefix("").Subrouter()
	protected.Use(middleware.AuthMiddleware)

	protected.HandleFunc("/profile", handlers.GetProfile(db)).Methods("GET")
	protected.HandleFunc("/profile", handlers.UpdateProfile(db)).Methods("PUT")
	protected.HandleFunc("/spots", handlers.AddSpotHandler(db)).Methods("POST")
	protected.HandleFunc("/spots/user", handlers.GetSpotsByUserHandler(db)).Methods("GET")

	return r
}
