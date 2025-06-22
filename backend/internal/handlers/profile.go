package handlers

import (
	"chillspot-backend/internal/models"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UpdateProfileRequest struct {
	Email    string `json:"email"`
	Username string `json:"username"`
}

func UpdateProfile(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID, ok := r.Context().Value("user_id").(string)
		if !ok {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Parse multipart form (max 10MB file size)
		if err := r.ParseMultipartForm(10 << 20); err != nil {
			http.Error(w, "Unable to parse form", http.StatusBadRequest)
			return
		}

		// Get form values
		email := r.FormValue("email")
		username := r.FormValue("username")
		file, handler, err := r.FormFile("profileImage")

		var profilePicPath *string
		profilePicUpdated := false

		// Handle profile picture upload
		if err == nil {
			defer file.Close()

			// Generate unique filename
			ext := filepath.Ext(handler.Filename)
			newFilename := uuid.New().String() + ext
			filePath := filepath.Join("uploads", newFilename)

			// Create upload directory if not exists
			if err := os.MkdirAll("uploads", os.ModePerm); err != nil {
				http.Error(w, "Failed to create upload directory", http.StatusInternalServerError)
				return
			}

			// Save file
			dst, err := os.Create(filePath)
			if err != nil {
				http.Error(w, "Failed to save image", http.StatusInternalServerError)
				return
			}
			defer dst.Close()

			if _, err := io.Copy(dst, file); err != nil {
				http.Error(w, "Failed to save image", http.StatusInternalServerError)
				return
			}

			// Store relative path
			relativePath := "/uploads/" + newFilename
			profilePicPath = &relativePath
			profilePicUpdated = true
		} else if err != http.ErrMissingFile {
			http.Error(w, "Invalid file upload", http.StatusBadRequest)
			return
		}

		// Validate input
		if email == "" || username == "" {
			http.Error(w, "Email and username are required", http.StatusBadRequest)
			return
		}

		// Check for existing email/username
		var count int64
		db.Model(&models.User{}).
			Where("(email = ? OR username = ?) AND id <> ?",
				email, username, userID).
			Count(&count)
		if count > 0 {
			http.Error(w, "Email or username already exists", http.StatusConflict)
			return
		}

		// Build update data
		updateData := map[string]interface{}{
			"email":    email,
			"username": username,
		}

		if profilePicUpdated {
			updateData["profile_pic"] = profilePicPath
		}

		// Update user
		result := db.Model(&models.User{}).
			Where("id = ?", userID).
			Updates(updateData)

		if result.Error != nil {
			http.Error(w, "Database error", http.StatusInternalServerError)
			return
		}

		if result.RowsAffected == 0 {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Build response
		response := map[string]interface{}{
			"message": "Profile updated successfully",
		}

		if profilePicUpdated {
			response["profile_pic"] = *profilePicPath
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(response)
	}
}

func GetProfile(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Get user ID from context
		userID, ok := r.Context().Value("user_id").(string)
		if !ok {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var user models.User
		if err := db.Where("id = ?", userID).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Construct full URL
		var profilePicURL string
		if user.ProfilePic != nil && *user.ProfilePic != "" {
			profilePicURL = fmt.Sprintf("http://%s%s", r.Host, *user.ProfilePic)
		}

		// Return user data
		userResponse := map[string]interface{}{
			"id":          user.ID,
			"username":    user.Username,
			"email":       user.Email,
			"profile_pic": profilePicURL,
			"xp":          user.XP,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(userResponse)
	}
}

// Implement your actual JWT extraction logic
func extractUserIDFromToken(tokenString string) (uuid.UUID, error) {
	// Parse JWT and extract user ID
	// This should be your actual implementation
	return uuid.Parse("user-id-from-token")
}
