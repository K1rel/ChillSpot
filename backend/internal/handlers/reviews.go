// handlers/reviews.go
package handlers

import (
	"encoding/json"
	"net/http"

	"chillspot-backend/internal/models"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

type CreateReviewInput struct {
	SpotID uuid.UUID `json:"spot_id"`
	Text   string    `json:"text"`
}

func CreateReviewHandler(db *gorm.DB) http.HandlerFunc {
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

		var input CreateReviewInput
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			http.Error(w, "Invalid input", http.StatusBadRequest)
			return
		}

		// Check if user has visited this spot
		var visited models.VisitedSpot
		if err := db.Where("user_id = ? AND spot_id = ?", userUUID, input.SpotID).First(&visited).Error; err != nil {
			http.Error(w, "You must visit a spot before reviewing it", http.StatusForbidden)
			return
		}

		// Check if review already exists
		var existingReview models.Review
		if err := db.Where("user_id = ? AND spot_id = ?", userUUID, input.SpotID).First(&existingReview).Error; err == nil {
			http.Error(w, "You've already reviewed this spot", http.StatusConflict)
			return
		}

		review := models.Review{
			UserID: userUUID,
			SpotID: input.SpotID,
			Text:   input.Text,
		}

		if err := db.Create(&review).Error; err != nil {
			http.Error(w, "Failed to create review", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(map[string]any{
			"message": "Review created successfully",
			"review":  review,
		})
	}
}

// handlers/reviews.go
func GetUserReviewsHandler(db *gorm.DB) http.HandlerFunc {
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

		// Query reviews with spot information using JOIN
		type ReviewWithSpot struct {
			models.Review
			SpotTitle string `json:"spot_title"`
		}

		var reviews []ReviewWithSpot

		query := `
            SELECT reviews.*, spots.title as spot_title 
            FROM reviews
            JOIN spots ON spots.id = reviews.spot_id
            WHERE reviews.user_id = ?
        `

		if err := db.Raw(query, userUUID).Scan(&reviews).Error; err != nil {
			http.Error(w, "Failed to fetch reviews", http.StatusInternalServerError)
			return
		}

		// Format response
		response := make([]map[string]interface{}, len(reviews))
		for i, review := range reviews {
			response[i] = map[string]interface{}{
				"id":         review.ID,
				"text":       review.Text,
				"likes":      review.Likes,
				"created_at": review.CreditedAt,
				"spot_title": review.SpotTitle,
			}
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

func GetSpotReviewsHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		spotID := vars["spotId"]

		var reviews []models.Review
		if err := db.Where("spot_id = ?", spotID).Find(&reviews).Error; err != nil {
			http.Error(w, "Failed to fetch reviews", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(reviews)
	}
}
