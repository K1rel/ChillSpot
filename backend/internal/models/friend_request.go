package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type FriendRequest struct {
	ID         uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	SenderID   uuid.UUID `gorm:"type:uuid;not null;index"`
	ReceiverID uuid.UUID `gorm:"type:uuid;not null;index"`
	Status     string    `gorm:"type:varchar(20);not null;default:'pending'"` // pending, accepted, declined
	CreatedAt  int64     `gorm:"autoCreateTime"`
	UpdatedAt  int64     `gorm:"autoUpdateTime"`

	// Relationships
	Sender   User `gorm:"foreignKey:SenderID;constraint:OnDelete:CASCADE;"`
	Receiver User `gorm:"foreignKey:ReceiverID;constraint:OnDelete:CASCADE;"`
}

func (fr *FriendRequest) BeforeCreate(tx *gorm.DB) (err error) {
	if fr.ID == uuid.Nil {
		fr.ID = uuid.New()
	}
	return
}

// Add unique constraint to prevent duplicate friend requests
func (FriendRequest) TableName() string {
	return "friend_requests"
}
