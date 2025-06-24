package routes

import (
	"chillspot-backend/internal/handlers"
	"chillspot-backend/internal/mailer"
	"chillspot-backend/internal/middleware"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

func SetupRoutes(db *gorm.DB, mailer *mailer.Mailer) *mux.Router {
	r := mux.NewRouter()
	r.Use(middleware.CorsMiddleware)
	r.HandleFunc("/register", handlers.Register(db)).Methods("POST")
	r.HandleFunc("/login", handlers.Login(db)).Methods("POST")

	// Protected routes
	protected := r.PathPrefix("").Subrouter()
	protected.Use(middleware.AuthMiddleware)

	protected.HandleFunc("/profile", handlers.GetProfile(db)).Methods("GET")
	protected.HandleFunc("/profile", handlers.UpdateProfile(db)).Methods("PUT")

	r.HandleFunc("/forgot-password", handlers.ForgotPassword(db, mailer)).Methods("POST")
	r.HandleFunc("/reset-password", handlers.ResetPassword(db)).Methods("POST")
	// Spot management
	protected.HandleFunc("/spots", handlers.AddSpotHandler(db)).Methods("POST")
	protected.HandleFunc("/spots/user", handlers.GetSpotsByUserHandler(db)).Methods("GET")

	// Visited spots endpoints
	protected.HandleFunc("/visited-spots", handlers.AddVisitedSpotHandler(db)).Methods("POST")
	protected.HandleFunc("/visited-spots", handlers.GetVisitedSpotsHandler(db)).Methods("GET")

	// Proximity check endpoint
	protected.HandleFunc("/spots/check-proximity", handlers.CheckProximityHandler(db)).Methods("POST")

	//Review endpoints
	protected.HandleFunc("/reviews", handlers.CreateReviewHandler(db)).Methods("POST")
	protected.HandleFunc("/reviews/user", handlers.GetUserReviewsHandler(db)).Methods("GET")
	// Add to routes.go
	protected.HandleFunc("/reviews/{id}", handlers.UpdateReviewHandler(db)).Methods("PUT")
	protected.HandleFunc("/reviews/{id}", handlers.DeleteReviewHandler(db)).Methods("DELETE")

	protected.HandleFunc("/spots/{id}", handlers.GetSpotHandler(db)).Methods("GET")
	protected.HandleFunc("/spots/{id}/like", handlers.LikeSpotHandler(db)).Methods("POST")
	protected.HandleFunc("/spots/{id}/visit", handlers.TrackVisitHandler(db)).Methods("POST")

	// Review routes
	protected.HandleFunc("/reviews/spot/{spotId}", handlers.GetSpotReviewsHandler(db)).Methods("GET")

	// Badge routes
	protected.HandleFunc("/badges/check", handlers.CheckBadgesHandler(db)).Methods("POST")
	protected.HandleFunc("/badges", handlers.GetUserBadgesHandler(db)).Methods("GET")

	//Friend routes
	// Friend routes
	protected.HandleFunc("/friends/search", handlers.SearchUsersHandler(db)).Methods("POST")
	protected.HandleFunc("/friends/request", handlers.SendFriendRequestHandler(db)).Methods("POST")
	protected.HandleFunc("/friends/requests", handlers.GetFriendRequestsHandler(db)).Methods("GET")
	protected.HandleFunc("/friends/accept", handlers.AcceptFriendRequestHandler(db)).Methods("POST")
	protected.HandleFunc("/friends/decline", handlers.DeclineFriendRequestHandler(db)).Methods("POST")
	protected.HandleFunc("/friends", handlers.GetFriendsHandler(db)).Methods("GET")
	protected.HandleFunc("/friends/spots", handlers.GetFriendsSpotsHandler(db)).Methods("GET")
	return r
}
