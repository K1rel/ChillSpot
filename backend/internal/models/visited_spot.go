package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type VisitedSpot struct {
	ID        uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID    uuid.UUID `gorm:"type:uuid;not null"`
	SpotID    uuid.UUID `gorm:"type:uuid;not null"`
	VisitedAt time.Time `gorm:"not null"`
	Notes     string    `gorm:"type:text"`
	User      User      `gorm:"foreignKey:UserID"`
	Spot      Spot      `gorm:"foreignKey:SpotID"`
}

func (v *VisitedSpot) BeforeCreate(tx *gorm.DB) (err error) {
	if v.ID == uuid.Nil {
		v.ID = uuid.New()
	}
	return
}
