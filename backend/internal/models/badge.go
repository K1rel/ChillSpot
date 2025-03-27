package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Badge struct {
	ID        uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID    uuid.UUID `gorm:"type:uuid;not null;index"`
	Name      string    `gorm:"type:varchar(100);not null"`
	ImagePath string    `gorm:"type:text;not null"` // Local path or URL
	CreatedAt int64     `gorm:"autoCreateTime"`
}

func (b *Badge) BeforeCreate(tx *gorm.DB) (err error) {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	return
}
