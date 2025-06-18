package handlers

import (
	"encoding/json"
	"math"
	"net/http"
	"time"

	"chillspot-backend/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type AddVisitedSpotInput struct {
	SpotID string `json:"spot_id"`
	Notes  string `json:"notes"`
}

type CheckProximityInput struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type ProximityResponse struct {
	NearbySpots []NearbySpot `json:"nearby_spots"`
}

type NearbySpot struct {
	SpotID    uuid.UUID `json:"spot_id"`
	Title     string    `json:"title"`
	Distance  float64   `json:"distance"` // in meters
	Latitude  float64   `json:"latitude"`
	Longitude float64   `json:"longitude"`
}

// Haversine formula to calculate distance between two points
func calculateDistance(lat1, lon1, lat2, lon2 float64) float64 {
	const R = 6371000 // Earth's radius in meters

	lat1Rad := lat1 * math.Pi / 180
	lat2Rad := lat2 * math.Pi / 180
	deltaLat := (lat2 - lat1) * math.Pi / 180
	deltaLon := (lon2 - lon1) * math.Pi / 180

	a := math.Sin(deltaLat/2)*math.Sin(deltaLat/2) +
		math.Cos(lat1Rad)*math.Cos(lat2Rad)*
			math.Sin(deltaLon/2)*math.Sin(deltaLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return R * c
}

func AddVisitedSpotHandler(db *gorm.DB) http.HandlerFunc {
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

		var input AddVisitedSpotInput
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			http.Error(w, "Invalid input", http.StatusBadRequest)
			return
		}

		spotUUID, err := uuid.Parse(input.SpotID)
		if err != nil {
			http.Error(w, "Invalid spot ID", http.StatusBadRequest)
			return
		}

		// Check if spot exists and belongs to user
		var spot models.Spot
		if err := db.Where("id = ? AND user_id = ?", spotUUID, userUUID).First(&spot).Error; err != nil {
			http.Error(w, "Spot not found", http.StatusNotFound)
			return
		}

		// Check if already visited
		var existingVisit models.VisitedSpot
		if err := db.Where("user_id = ? AND spot_id = ?", userUUID, spotUUID).First(&existingVisit).Error; err == nil {
			http.Error(w, "Spot already marked as visited", http.StatusConflict)
			return
		}

		visitedSpot := models.VisitedSpot{
			UserID:    userUUID,
			SpotID:    spotUUID,
			VisitedAt: time.Now(),
			Notes:     input.Notes,
		}

		if err := db.Create(&visitedSpot).Error; err != nil {
			http.Error(w, "Failed to add visited spot", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(map[string]any{
			"message":      "Visited spot added",
			"visited_spot": visitedSpot,
		})
	}
}

func GetVisitedSpotsHandler(db *gorm.DB) http.HandlerFunc {
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

		var visitedSpots []models.VisitedSpot
		if err := db.Preload("Spot").Where("user_id = ?", userUUID).Find(&visitedSpots).Error; err != nil {
			http.Error(w, "Failed to fetch visited spots", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(visitedSpots)
	}
}

func CheckProximityHandler(db *gorm.DB) http.HandlerFunc {
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

		var input CheckProximityInput
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			http.Error(w, "Invalid input", http.StatusBadRequest)
			return
		}

		// Get all user's spots
		var spots []models.Spot
		if err := db.Where("user_id = ?", userUUID).Find(&spots).Error; err != nil {
			http.Error(w, "Failed to fetch spots", http.StatusInternalServerError)
			return
		}

		// Get already visited spots
		var visitedSpots []models.VisitedSpot
		if err := db.Where("user_id = ?", userUUID).Find(&visitedSpots).Error; err != nil {
			http.Error(w, "Failed to fetch visited spots", http.StatusInternalServerError)
			return
		}

		// Create map of visited spot IDs
		visitedMap := make(map[uuid.UUID]bool)
		for _, visited := range visitedSpots {
			visitedMap[visited.SpotID] = true
		}

		// Check proximity (within 50 meters)
		const proximityThreshold = 50.0
		var nearbySpots []NearbySpot

		for _, spot := range spots {
			// Skip if already visited
			if visitedMap[spot.ID] {
				continue
			}

			distance := calculateDistance(
				input.Latitude, input.Longitude,
				spot.Latitude, spot.Longitude,
			)

			if distance <= proximityThreshold {
				nearbySpots = append(nearbySpots, NearbySpot{
					SpotID:    spot.ID,
					Title:     spot.Title,
					Distance:  distance,
					Latitude:  spot.Latitude,
					Longitude: spot.Longitude,
				})
			}
		}

		response := ProximityResponse{
			NearbySpots: nearbySpots,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}
