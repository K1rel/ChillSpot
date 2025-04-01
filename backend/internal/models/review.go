package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Review struct {
	ID         uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID     uuid.UUID `gorm:"type:uuid;not null;index"`
	SpotID     uuid.UUID `gorm:"type:uuid;not null;index"`
	Likes      int       `gorm:"default:0"`
	Text       string    `gorm:"type:varchar(500); not null"` // maksimum dolzhina na recenzija da bide 500 karakteri
	CreditedAt int64     `gorm:"autoCreateTime"`
}

func (r *Review) BeforeCreate(tx *gorm.DB) (err error) {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	return
}
