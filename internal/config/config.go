package config

import (
	"strings"
	"github.com/spf13/viper"
)

type AppConfig struct {
	Provider string
	APIKey   string
	Port     int
	Models   map[string]string
}

func Load() AppConfig {
	viper.SetConfigName("config")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()

	// env overrides (e.g. ANTHROPIC_API_KEY)
	viper.SetEnvPrefix("COLUMUSE")
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	if err := viper.ReadInConfig(); err != nil {
		// ignore missing config file – everything comes from env
	}

	return AppConfig{
		Provider: viper.GetString("provider"),
		APIKey:   viper.GetString("api_key"),
		Port:     viper.GetInt("port"),
		Models:   viper.GetStringMapString("models"),
	}
}
