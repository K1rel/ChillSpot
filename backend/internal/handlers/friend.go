package handlers

import (
	"chillspot-backend/internal/models"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type SearchUsersRequest struct {
	Query string `json:"query"`
	Limit int    `json:"limit,omitempty"`
}

func SearchUsersHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Get user ID from context
		userID, ok := r.Context().Value("user_id").(string)
		if !ok || userID == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		// Parse request body
		var req SearchUsersRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		if req.Limit == 0 {
			req.Limit = 10
		}

		// Get current user
		var currentUser models.User
		if err := db.First(&currentUser, userUUID).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Search users
		users, err := currentUser.SearchUsers(db, req.Query, req.Limit)
		if err != nil {
			http.Error(w, "Failed to search users", http.StatusInternalServerError)
			return
		}

		// Filter out existing friends and pending requests
		var filteredUsers []models.User
		for _, user := range users {
			// Check for existing friend relationship
			var count int64
			db.Raw(`
				SELECT COUNT(*) 
				FROM user_friends 
				WHERE (user_id = ? AND friend_id = ?) 
				   OR (user_id = ? AND friend_id = ?)`,
				currentUser.ID, user.ID, user.ID, currentUser.ID).Scan(&count)

			if count > 0 {
				continue
			}

			// Check for pending friend request
			var frCount int64
			db.Model(&models.FriendRequest{}).
				Where("((sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)) AND status = 'pending'",
					currentUser.ID, user.ID, user.ID, currentUser.ID).
				Count(&frCount)

			if frCount == 0 {
				filteredUsers = append(filteredUsers, user)
			}
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(users)
	}
}

func SendFriendRequestHandler(db *gorm.DB) http.HandlerFunc {

	return func(w http.ResponseWriter, r *http.Request) {
		// Get user ID from context
		userID, ok := r.Context().Value("user_id").(string)
		if !ok || userID == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		senderUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		// Parse request
		var req struct {
			ReceiverID string `json:"receiver_id"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		receiverUUID, err := uuid.Parse(req.ReceiverID)
		if err != nil {
			http.Error(w, "Invalid receiver ID", http.StatusBadRequest)
			return
		}
		fmt.Printf("Received friend request: Sender=%s, Receiver=%s\n",
			senderUUID, receiverUUID)
		// Get sender user
		var sender models.User
		if err := db.First(&sender, senderUUID).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Send friend request
		fr, err := sender.SendFriendRequest(db, receiverUUID)
		if err != nil {
			fmt.Printf("Friend request error: %v\n", err)
			if errors.Is(err, gorm.ErrDuplicatedKey) {
				http.Error(w, "Friend request already exists", http.StatusConflict)
			} else if err.Error() == "already friends" {
				http.Error(w, "Already friends", http.StatusConflict)
			} else {
				http.Error(w, "Failed to send friend request", http.StatusInternalServerError)
			}
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(fr)
	}
}

func GetFriendRequestsHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Get user ID from context
		userID, ok := r.Context().Value("user_id").(string)
		if !ok || userID == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		// Get current user
		var currentUser models.User
		if err := db.First(&currentUser, userUUID).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		requests, err := currentUser.GetPendingFriendRequests(db)
		if err != nil {
			http.Error(w, "Failed to get friend requests", http.StatusInternalServerError)
			return
		}

		// Create a custom response with necessary user details
		type FriendRequestResponse struct {
			ID     uuid.UUID `json:"id"`
			Sender struct {
				ID         uuid.UUID `json:"id"`
				Username   string    `json:"username"`
				ProfilePic *string   `json:"profile_pic"`
			} `json:"sender"`
			CreatedAt int64 `json:"created_at"`
		}

		var response []FriendRequestResponse
		for _, req := range requests {
			res := FriendRequestResponse{
				ID:        req.ID,
				CreatedAt: req.CreatedAt,
			}
			res.Sender.ID = req.Sender.ID
			res.Sender.Username = req.Sender.Username
			res.Sender.ProfilePic = req.Sender.ProfilePic
			response = append(response, res)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

func AcceptFriendRequestHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Get user ID from context
		userID, ok := r.Context().Value("user_id").(string)
		if !ok || userID == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		// Parse request
		var req struct {
			RequestID string `json:"request_id"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		requestUUID, err := uuid.Parse(req.RequestID)
		if err != nil {
			http.Error(w, "Invalid request ID", http.StatusBadRequest)
			return
		}

		// Get current user
		var currentUser models.User
		if err := db.First(&currentUser, userUUID).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Accept request
		if err := currentUser.AcceptFriendRequest(db, requestUUID); err != nil {
			http.Error(w, "Failed to accept friend request", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Friend request accepted"})
	}
}

func DeclineFriendRequestHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Get user ID from context
		userID, ok := r.Context().Value("user_id").(string)
		if !ok || userID == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		// Parse request
		var req struct {
			RequestID string `json:"request_id"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		requestUUID, err := uuid.Parse(req.RequestID)
		if err != nil {
			http.Error(w, "Invalid request ID", http.StatusBadRequest)
			return
		}

		// Get current user
		var currentUser models.User
		if err := db.First(&currentUser, userUUID).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Decline request
		if err := currentUser.DeclineFriendRequest(db, requestUUID); err != nil {
			http.Error(w, "Failed to decline friend request", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Friend request declined"})
	}
}

func GetFriendsHandler(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Get user ID from context
		userID, ok := r.Context().Value("user_id").(string)
		if !ok || userID == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		userUUID, err := uuid.Parse(userID)
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		// Get user with friends
		var user models.User
		if err := db.Preload("Friends").First(&user, userUUID).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Create response with XP
		type FriendResponse struct {
			ID         string  `json:"id"`
			Username   string  `json:"username"`
			ProfilePic *string `json:"profile_pic"`
			XP         int     `json:"xp"` // Add your XP field here
		}

		var friendsResponse []FriendResponse
		for _, friend := range user.Friends {
			friendsResponse = append(friendsResponse, FriendResponse{
				ID:         friend.ID.String(),
				Username:   friend.Username,
				ProfilePic: friend.ProfilePic,
				XP:         friend.XP, // Make sure this field exists in your User model
			})
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(friendsResponse)
	}
}
