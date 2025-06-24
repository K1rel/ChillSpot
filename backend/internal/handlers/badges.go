// handlers/badges.goAdd commentMore actions
package handlers

import (
	"encoding/json"
	"net/http"

	"chillspot-backend/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BadgeResponse struct {
	ID        uuid.UUID `json:"ID"`        // Changed to match Flutter expectation
	UserID    uuid.UUID `json:"UserID"`    // Added UserID
	Name      string    `json:"Name"`      // Changed to match Flutter expectation
	ImagePath string    `json:"ImagePath"` // Changed to match Flutter expectation
	CreatedAt int64     `json:"createdAt"`
}

type BadgeCheckResponse struct {
	NewBadges []BadgeResponse `json:"newBadges"`
	AllBadges []BadgeResponse `json:"allBadges"`
}

func CheckBadgesHandler(db *gorm.DB) http.HandlerFunc {
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

		// Get user counts
		var counts struct {
			Reviews int64
			Visits  int64
			Spots   int64
			Friends int64
			Likes   int64
		}

		db.Model(&models.Review{}).Where("user_id = ?", userUUID).Count(&counts.Reviews)
		db.Model(&models.VisitedSpot{}).Where("user_id = ?", userUUID).Count(&counts.Visits)
		db.Model(&models.Spot{}).Where("user_id = ?", userUUID).Count(&counts.Spots)
		db.Table("user_friends").Where("user_id = ?", userUUID).Count(&counts.Friends)
		db.Model(&models.Like{}).Where("user_id = ?", userUUID).Count(&counts.Likes)

		// Get all badge definitions
		var definitions []models.BadgeDefinition
		db.Find(&definitions)

		// Award new badges
		var newBadges []models.Badge
		for _, def := range definitions {
			var count int64
			switch def.Type {
			case models.BadgeReviews:
				count = counts.Reviews
			case models.BadgeVisits:
				count = counts.Visits
			case models.BadgeSpots:
				count = counts.Spots
			case models.BadgeFriends:
				count = counts.Friends
			case models.BadgeLikes:
				count = counts.Likes
			}

			if count >= int64(def.Threshold) {
				// Check if user already has this badge
				var existing models.Badge
				if db.Where("badge_def_id = ? AND user_id = ?", def.ID, userUUID).First(&existing).Error != nil {
					// Award badge if not exists
					badge := models.Badge{
						UserID:     userUUID,
						Name:       def.Name,
						ImagePath:  def.ImagePath,
						BadgeDefID: def.ID,
					}
					if err := db.Create(&badge).Error; err == nil {
						newBadges = append(newBadges, badge)
					}
				}
			}
		}

		// Get all user badges
		var allBadges []models.Badge
		db.Where("user_id = ?", userUUID).Find(&allBadges)

		// Convert to response format
		var newBadgeResponses []BadgeResponse
		for _, b := range newBadges {
			newBadgeResponses = append(newBadgeResponses, BadgeResponse{
				ID:        b.ID,
				UserID:    b.UserID,
				Name:      b.Name,
				ImagePath: b.ImagePath,
				CreatedAt: b.CreatedAt,
			})
		}

		var allBadgeResponses []BadgeResponse
		for _, b := range allBadges {
			allBadgeResponses = append(allBadgeResponses, BadgeResponse{
				ID:        b.ID,
				UserID:    b.UserID,
				Name:      b.Name,
				ImagePath: b.ImagePath,
				CreatedAt: b.CreatedAt,
			})
		}

		response := BadgeCheckResponse{
			NewBadges: newBadgeResponses,
			AllBadges: allBadgeResponses,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

func GetUserBadgesHandler(db *gorm.DB) http.HandlerFunc {
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

		var badges []models.Badge
		if err := db.Where("user_id = ?", userUUID).Find(&badges).Error; err != nil {
			http.Error(w, "Failed to get badges", http.StatusInternalServerError)
			return
		}

		var response []BadgeResponse
		for _, b := range badges {
			response = append(response, BadgeResponse{
				ID:        b.ID,
				UserID:    b.UserID,
				Name:      b.Name,
				ImagePath: b.ImagePath,
				CreatedAt: b.CreatedAt,
			})
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}
