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
	Latitude           float64          `gorm:"type:double precision;not null"`
	Longitude          float64          `gorm:"type:double precision;not null"`
	Title              string           `gorm:"type:varchar(100);not null"`
	Description        string           `gorm:"type:text;not null"`
	DayImage           *string          `gorm:"type:text"`
	NightImage         *string          `gorm:"type:text"`
	RecommendedWeather WeatherCondition `gorm:"type:varchar(20)"`
	VisitCount         uint             `gorm:"default:0"`
	// favorites_count kje se inkrementira so funkcija, namesto sekoj pat kveri da se izvrshuva
	FavoritesCount uint `gorm:"default:0" json:"favorites_count"`
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

func (s *Spot) BeforeCreate(tx *gorm.DB) (err error) {
	s.ID = uuid.New()
	return nil
}
