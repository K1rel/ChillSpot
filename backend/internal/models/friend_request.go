package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type FriendRequest struct {
	ID         uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	SenderID   uuid.UUID `gorm:"type:uuid;not null;index" json:"sender_id"`
	ReceiverID uuid.UUID `gorm:"type:uuid;not null;index" json:"receiver_id"`
	Status     string    `gorm:"type:varchar(20);not null;default:'pending'" json:"status"` // pending, accepted, declined
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

func (FriendRequest) TableName() string {
	return "friend_requests"
}
