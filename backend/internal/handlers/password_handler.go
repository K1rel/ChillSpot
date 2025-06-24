package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"chillspot-backend/internal/mailer"
	"chillspot-backend/internal/models"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type ForgotPasswordInput struct {
	Email string `json:"email"`
}

func ForgotPassword(db *gorm.DB, mailer *mailer.Mailer) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var input ForgotPasswordInput
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			http.Error(w, "Invalid input", http.StatusBadRequest)
			return
		}

		var user models.User
		if err := db.Where("email = ?", input.Email).First(&user).Error; err != nil {
			// For security, don't reveal if email exists
			w.WriteHeader(http.StatusOK)
			json.NewEncoder(w).Encode(map[string]string{"message": "If the email exists, a reset link has been sent"})
			return
		}

		token := uuid.New().String()
		resetToken := models.PasswordResetToken{
			Token:  token,
			UserID: user.ID,
		}

		if err := db.Create(&resetToken).Error; err != nil {
			http.Error(w, "Error creating reset token", http.StatusInternalServerError)
			return
		}

		if err := mailer.SendResetPassword(user.Email, resetToken.Code); err != nil {
			db.Delete(&resetToken) // Clean up if email fails
			http.Error(w, "Error sending email", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Password reset email sent"})
	}
}

type ResetPasswordInput struct {
	Email       string `json:"email"`
	ResetCode   string `json:"reset_code"`
	NewPassword string `json:"new_password"`
}

func ResetPassword(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var input ResetPasswordInput
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			http.Error(w, "Invalid input", http.StatusBadRequest)
			return
		}

		// First, find the user by email
		var user models.User
		if err := db.Where("email = ?", input.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Then find the reset token for this user
		var resetToken models.PasswordResetToken
		if err := db.Where("user_id = ? AND code = ?", user.ID, input.ResetCode).First(&resetToken).Error; err != nil {
			http.Error(w, "Invalid or expired code", http.StatusBadRequest)
			return
		}

		if time.Now().After(resetToken.ExpiresAt) {
			db.Delete(&resetToken)
			http.Error(w, "Code expired", http.StatusBadRequest)
			return
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.NewPassword), bcrypt.DefaultCost)
		if err != nil {
			http.Error(w, "Error hashing password", http.StatusInternalServerError)
			return
		}

		// Update the existing user's password
		if err := db.Model(&user).Update("password", string(hashedPassword)).Error; err != nil {
			http.Error(w, "Error updating password", http.StatusInternalServerError)
			return
		}

		db.Delete(&resetToken) // Clean up used token

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Password reset successful"})
	}
}
