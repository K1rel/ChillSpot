package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID         uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	Username   string    `gorm:"type:varchar(50);uniqueIndex;not null"`
	Password   string    `gorm:"type:text;not null"` // Store hashed password
	ProfilePic *string   `gorm:"type:text"`          // Optional
	Favorites  []Spot    `gorm:"many2many:user_favorites;"`
	Friends    []*User   `gorm:"many2many:user_friends;"`
	CreatedAt  int64     `gorm:"autoCreateTime"`
}

func (u *User) BeforeCreate(tx *gorm.DB) (err error) {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return
}
