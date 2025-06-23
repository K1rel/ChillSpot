package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BadgeType string

const (
	BadgeReviews BadgeType = "reviews"
	BadgeVisits  BadgeType = "visits"
	BadgeSpots   BadgeType = "spots"
	BadgeFriends BadgeType = "friends"
	BadgeLikes   BadgeType = "likes"
)

type BadgeDefinition struct {
	ID        uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Name      string    `gorm:"type:varchar(100);not null"`
	ImagePath string    `gorm:"type:text;not null"`
	Type      BadgeType `gorm:"type:varchar(50);not null"`
	Threshold int       `gorm:"not null"`
}

func (bd *BadgeDefinition) BeforeCreate(tx *gorm.DB) (err error) {
	if bd.ID == uuid.Nil {
		bd.ID = uuid.New()
	}
	return
}
