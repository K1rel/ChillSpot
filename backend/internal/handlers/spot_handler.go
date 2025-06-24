package handlers

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"chillspot-backend/internal/models"

	"gorm.io/gorm"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
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

		// Parse multipart form
		err = r.ParseMultipartForm(32 << 20) // 32 MB max
		if err != nil {
			http.Error(w, "Failed to parse form data", http.StatusBadRequest)
			return
		}

		// Get form values
		latitudeStr := r.FormValue("latitude")
		longitudeStr := r.FormValue("longitude")
		title := r.FormValue("title")
		description := r.FormValue("description")
		weather := r.FormValue("weather")

		// Convert coordinates
		latitude, err := strconv.ParseFloat(latitudeStr, 64)
		if err != nil {
			http.Error(w, "Invalid latitude", http.StatusBadRequest)
			return
		}

		longitude, err := strconv.ParseFloat(longitudeStr, 64)
		if err != nil {
			http.Error(w, "Invalid longitude", http.StatusBadRequest)
			return
		}
		altitudeStr := r.FormValue("altitude")
		var altitude float64
		if altitudeStr != "" {
			altitude, err = strconv.ParseFloat(altitudeStr, 64)
			if err != nil {
				http.Error(w, "Invalid altitude", http.StatusBadRequest)
				return
			}
		}
		// Create spot
		spot := models.Spot{
			UserID:             userUUID,
			Latitude:           latitude,
			Longitude:          longitude,
			Altitude:           altitude,
			Title:              title,
			Description:        description,
			RecommendedWeather: models.WeatherCondition(weather),
			CreatedAt:          time.Now(),
			UpdatedAt:          time.Now(),
		}

		// Save day image
		dayImagePath, err := saveImage(r, "day_image")
		if err != nil {
			http.Error(w, "Failed to save day image", http.StatusInternalServerError)
			return
		}
		spot.DayImage = &dayImagePath

		// Save night image
		nightImagePath, err := saveImage(r, "night_image")
		if err != nil {
			http.Error(w, "Failed to save night image", http.StatusInternalServerError)
			return
		}
		spot.NightImage = &nightImagePath

		// Save to database
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

func saveImage(r *http.Request, fieldName string) (string, error) {
	file, header, err := r.FormFile(fieldName)
	if err != nil {
		if err == http.ErrMissingFile {
			return "", nil // No file is acceptable
		}
		return "", err
	}
	defer file.Close()

	// Create images directory if it doesn't exist
	err = os.MkdirAll("images", os.ModePerm)
	if err != nil {
		return "", err
	}

	// Create unique filename
	ext := filepath.Ext(header.Filename)
	if ext == "" {
		ext = ".jpg"
	}
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	filePath := filepath.Join("images", filename)

	// Save file
	out, err := os.Create(filePath)
	if err != nil {
		return "", err
	}
	defer out.Close()

	_, err = io.Copy(out, file)
	if err != nil {
		return "", err
	}

	// Return just the filename for database storage
	return filename, nil
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

func GetSpotHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		spotID := vars["id"]

		var spot models.Spot
		if err := db.Preload("User").Where("id = ?", spotID).First(&spot).Error; err != nil {
			http.Error(w, "Spot not found", http.StatusNotFound)
			return
		}

		// Get distinct users who visited this spot
		var visitCount int64
		err := db.Model(&models.VisitedSpot{}).
			Distinct("user_id").
			Where("spot_id = ?", spotID).
			Count(&visitCount).Error

		if err != nil {
			http.Error(w, "Failed to count visits", http.StatusInternalServerError)
			return
		}

		// Get likes count
		var likesCount int64
		db.Model(&models.Like{}).Where("spot_id = ?", spotID).Count(&likesCount)

		// Update spot counts
		spot.FavoritesCount = uint(likesCount)
		spot.VisitCount = uint(visitCount)

		// Create response with proper field names
		response := map[string]interface{}{
			"ID":                 spot.ID,
			"UserID":             spot.UserID,
			"User":               spot.User,
			"Latitude":           spot.Latitude,
			"Longitude":          spot.Longitude,
			"Title":              spot.Title,
			"Description":        spot.Description,
			"RecommendedWeather": spot.RecommendedWeather,
			"CreatedAt":          spot.CreatedAt,
			"UpdatedAt":          spot.UpdatedAt,
			"favorites_count":    spot.FavoritesCount,
			"visit_count":        spot.VisitCount,
		}

		// Add image fields with proper handling
		if spot.DayImage != nil && *spot.DayImage != "" {
			response["DayImage"] = filepath.Base(*spot.DayImage)
		}
		if spot.NightImage != nil && *spot.NightImage != "" {
			response["NightImage"] = filepath.Base(*spot.NightImage)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

type Like struct {
	ID        uuid.UUID `gorm:"type:uuid;default:uuid_generate_v4();primary_key"`
	UserID    uuid.UUID `gorm:"type:uuid;not null"`
	SpotID    uuid.UUID `gorm:"type:uuid;not null"`
	CreatedAt time.Time `gorm:"not null"`
}

func LikeSpotHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		spotID := vars["id"]

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

		spotUUID, err := uuid.Parse(spotID)
		if err != nil {
			http.Error(w, "Invalid spot ID", http.StatusBadRequest)
			return
		}

		// Check if user already liked this spot
		var existingLike models.Like
		result := db.Where("user_id = ? AND spot_id = ?", userUUID, spotUUID).First(&existingLike)

		if result.Error == nil {
			// User already liked this spot
			http.Error(w, "User already liked this spot", http.StatusBadRequest)
			return
		} else if !errors.Is(result.Error, gorm.ErrRecordNotFound) {
			// Some other database error
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}

		// Create new like
		like := models.Like{
			UserID:    userUUID,
			SpotID:    spotUUID,
			CreatedAt: time.Now(),
		}

		if err := db.Create(&like).Error; err != nil {
			http.Error(w, "Failed to create like", http.StatusInternalServerError)
			return
		}

		// Update spot's favorites count
		if err := db.Model(&models.Spot{}).Where("id = ?", spotUUID).Update("favorites_count", gorm.Expr("favorites_count + 1")).Error; err != nil {
			http.Error(w, "Failed to update spot", http.StatusInternalServerError)
			return
		}

		// Return updated spot
		var spot models.Spot
		if err := db.Where("id = ?", spotUUID).First(&spot).Error; err != nil {
			http.Error(w, "Failed to fetch spot", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(spot)
	}
}

func TrackVisitHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		spotID := vars["id"]

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

		spotUUID, err := uuid.Parse(spotID)
		if err != nil {
			http.Error(w, "Invalid spot ID", http.StatusBadRequest)
			return
		}

		// Check if visit already exists today
		var existingVisit models.VisitedSpot
		today := time.Now().Format("2006-01-02")
		result := db.Where("user_id = ? AND spot_id = ? AND DATE(visited_at) = ?",
			userUUID, spotUUID, today).First(&existingVisit)

		if result.Error == nil {
			// Visit already tracked today
			w.WriteHeader(http.StatusOK)
			return
		}

		// Create new visit
		visit := models.VisitedSpot{
			UserID:    userUUID,
			SpotID:    spotUUID,
			VisitedAt: time.Now(),
		}

		if err := db.Create(&visit).Error; err != nil {
			http.Error(w, "Failed to track visit", http.StatusInternalServerError)
			return
		}

		// Update spot's visit count
		if err := db.Model(&models.Spot{}).Where("id = ?", spotUUID).
			Update("visit_count", gorm.Expr("visit_count + 1")).Error; err != nil {
			http.Error(w, "Failed to update spot", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
	}
}
