package models

import (
	"math/rand"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PasswordResetToken struct {
	Token     string    `gorm:"primaryKey" json:"token"`
	UserID    uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	User      User      `gorm:"constraint:OnDelete:CASCADE;"`
	ExpiresAt time.Time `gorm:"not null" json:"expires_at"`
	Code      string    `gorm:"type:varchar(6);not null" json:"-"` // Add this field
}

func (prt *PasswordResetToken) BeforeCreate(tx *gorm.DB) (err error) {
	prt.ExpiresAt = time.Now().Add(15 * time.Minute)
	prt.Code = generateRandomCode(6) // Generate numeric code
	return
}

func generateRandomCode(length int) string {
	b := make([]byte, length)
	for i := range b {
		b[i] = byte(rand.Intn(10) + 48) // 0-9 ASCII
	}
	return string(b)
}
