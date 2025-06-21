package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID         uuid.UUID `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	Username   string    `gorm:"type:varchar(50);uniqueIndex;not null" json:"username"`
	Password   string    `gorm:"type:text;not null" json:"-"` // Never output password
	Email      string    `gorm:"type:varchar(100);uniqueIndex;not null" json:"email"`
	ProfilePic *string   `gorm:"type:text" json:"profile_pic"` // Optional
	XP         int       `gorm:"default:0" json:"xp"`
	Favorites  []Spot    `gorm:"many2many:user_favorites;"`
	Friends    []*User   `gorm:"many2many:user_friends;"`

	// Friend requests sent by this user
	SentFriendRequests []FriendRequest `gorm:"foreignKey:SenderID"`
	// Friend requests received by this user
	ReceivedFriendRequests []FriendRequest `gorm:"foreignKey:ReceiverID"`

	CreatedAt int64 `gorm:"autoCreateTime"`
}

func (u *User) BeforeCreate(tx *gorm.DB) (err error) {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return
}

func (u *User) SendFriendRequest(db *gorm.DB, receiverID uuid.UUID) (*FriendRequest, error) {
	// Check if friend request already exists

	var existingRequest FriendRequest
	result := db.Where("sender_id = ? AND receiver_id = ? AND status = 'pending'", u.ID, receiverID).First(&existingRequest)
	if result.Error == nil {
		return nil, gorm.ErrDuplicatedKey
	}

	// Check if they are already friends
	var friendship User
	err := db.Model(u).Association("Friends").Find(&friendship, "id = ?", receiverID)
	if err == nil && friendship.ID == receiverID {
		return nil, gorm.ErrDuplicatedKey // Already friends
	}

	friendRequest := &FriendRequest{
		SenderID:   u.ID,
		ReceiverID: receiverID,
		Status:     "pending",
	}

	if err := db.Create(friendRequest).Error; err != nil {
		return nil, err
	}

	return friendRequest, nil
}

func (u *User) AcceptFriendRequest(db *gorm.DB, requestID uuid.UUID) error {
	var friendRequest FriendRequest
	if err := db.Where("id = ? AND receiver_id = ? AND status = 'pending'", requestID, u.ID).First(&friendRequest).Error; err != nil {
		return err
	}

	// Start transaction
	tx := db.Begin()

	// Update friend request status
	if err := tx.Model(&friendRequest).Update("status", "accepted").Error; err != nil {
		tx.Rollback()
		return err
	}

	// Add to friends relationship (both ways)
	var sender User
	if err := tx.First(&sender, friendRequest.SenderID).Error; err != nil {
		tx.Rollback()
		return err
	}

	if err := tx.Model(u).Association("Friends").Append(&sender); err != nil {
		tx.Rollback()
		return err
	}

	if err := tx.Model(&sender).Association("Friends").Append(u); err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
}

func (u *User) DeclineFriendRequest(db *gorm.DB, requestID uuid.UUID) error {
	var friendRequest FriendRequest
	if err := db.Where("id = ? AND receiver_id = ? AND status = 'pending'", requestID, u.ID).First(&friendRequest).Error; err != nil {
		return err
	}

	return db.Model(&friendRequest).Update("status", "declined").Error
}

func (u *User) GetPendingFriendRequests(db *gorm.DB) ([]FriendRequest, error) {
	var requests []FriendRequest
	err := db.Where("receiver_id = ? AND status = 'pending'", u.ID).
		Preload("Sender").
		Order("created_at DESC").
		Find(&requests).Error
	return requests, err
}

func (u *User) SearchUsers(db *gorm.DB, query string, limit int) ([]User, error) {
	var users []User
	err := db.Where("username ILIKE ? OR email ILIKE ?", "%"+query+"%", "%"+query+"%").
		Where("id != ?", u.ID). // Exclude current user
		Limit(limit).
		Find(&users).Error
	return users, err
}
