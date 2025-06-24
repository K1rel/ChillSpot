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

func GetUserReviewsHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID, ok := r.Context().Value("user_id").(string)
		if !ok {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		var reviews []models.Review
		if err := db.Preload("Spot").Where("user_id = ?", userUUID).Find(&reviews).Error; err != nil {
			http.Error(w, "Failed to fetch reviews", http.StatusInternalServerError)
			return
		}

		// Format response
		response := make([]map[string]interface{}, len(reviews))
		for i, r := range reviews {
			response[i] = map[string]interface{}{
				"id":         r.ID,
				"spot_id":    r.SpotID,
				"spot_title": r.Spot.Title,
				"text":       r.Text,
				"likes":      r.Likes,
				"created_at": r.CreditedAt,
			}
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

func UpdateReviewHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		reviewID := vars["id"]

		userID, ok := r.Context().Value("user_id").(string)
		if !ok {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		var input struct {
			Text string `json:"text"`
		}
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		var review models.Review
		if err := db.Where("id = ? AND user_id = ?", reviewID, userUUID).First(&review).Error; err != nil {
			http.Error(w, "Review not found or unauthorized", http.StatusNotFound)
			return
		}

		review.Text = input.Text
		if err := db.Save(&review).Error; err != nil {
			http.Error(w, "Failed to update review", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Review updated successfully"})
	}
}

func DeleteReviewHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		reviewID := vars["id"]

		userID, ok := r.Context().Value("user_id").(string)
		if !ok {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		result := db.Where("id = ? AND user_id = ?", reviewID, userUUID).Delete(&models.Review{})
		if result.Error != nil {
			http.Error(w, "Failed to delete review", http.StatusInternalServerError)
			return
		}

		if result.RowsAffected == 0 {
			http.Error(w, "Review not found or unauthorized", http.StatusNotFound)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Review deleted successfully"})
	}
}
