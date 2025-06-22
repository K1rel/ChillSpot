package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type WeatherCondition string

const (
	Sunny  WeatherCondition = "sunny"
	Rainy  WeatherCondition = "rainy"
	Cloudy WeatherCondition = "cloudy"
	Snowy  WeatherCondition = "snowy"
)

type Spot struct {
	ID                 uuid.UUID        `gorm:"type:uuid;default:gen_random_uuid();primaryKey"`
	UserID             uuid.UUID        `gorm:"type:uuid;not null"`
	User               User             `gorm:"foreignKey:UserID"`
	Latitude           float64          `gorm:"type:double precision;not null"`
	Longitude          float64          `gorm:"type:double precision;not null"`
	Altitude           float64          `gorm:"type:double precision;not null;default:0"`
	Title              string           `gorm:"type:varchar(100);not null"`
	Description        string           `gorm:"type:text;not null"`
	DayImage           *string          `gorm:"type:text"`
	NightImage         *string          `gorm:"type:text"`
	RecommendedWeather WeatherCondition `gorm:"type:varchar(100)"`
	VisitCount         uint             `gorm:"default:0"`
	FavoritesCount     uint             `gorm:"default:0" json:"favorites_count"`
	CreatedAt          time.Time
	UpdatedAt          time.Time
}

func (s *Spot) BeforeCreate(tx *gorm.DB) (err error) {
	s.ID = uuid.New()
	return nil
}
