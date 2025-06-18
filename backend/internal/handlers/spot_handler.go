package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"chillspot-backend/internal/models"

	"gorm.io/gorm"

	"github.com/google/uuid"
)

type AddSpotInput struct {
	Latitude    float64 `json:"latitude"`
	Longitude   float64 `json:"longitude"`
	Title       string  `json:"title"`
	Description string  `json:"description"`
	Weather     string  `json:"weather"`
	UserID      string  `json:"user_id"`
}

func AddSpotHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Get user ID from context
		userID, ok := r.Context().Value("user_id").(string)
		if !ok || userID == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		var input struct {
			Latitude    float64 `json:"latitude"`
			Longitude   float64 `json:"longitude"`
			Title       string  `json:"title"`
			Description string  `json:"description"`
			Weather     string  `json:"weather"`
		}

		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			http.Error(w, "Invalid input", http.StatusBadRequest)
			return
		}

		spot := models.Spot{
			UserID:             userUUID,
			Latitude:           input.Latitude,
			Longitude:          input.Longitude,
			Title:              input.Title,
			Description:        input.Description,
			RecommendedWeather: models.WeatherCondition(input.Weather),
			CreatedAt:          time.Now(),
			UpdatedAt:          time.Now(),
		}

		if err := db.Create(&spot).Error; err != nil {
			http.Error(w, "Failed to create spot", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(map[string]any{
			"message": "Spot created",
			"spot":    spot,
		})
	}
}

func GetSpotsByUserHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		userID, ok := r.Context().Value("user_id").(string)
		if !ok || userID == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		var spots []models.Spot
		if err := db.Where("user_id = ?", userUUID).Find(&spots).Error; err != nil {
			http.Error(w, "Failed to fetch spots", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(spots)
	}
}
