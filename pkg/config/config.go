package config

import "gopkg.in/yaml.v2"

type Config struct {
	Metrics []Metric `yaml:"metrics"`
}

type Metric struct {
	Name   string              `yaml:"name"`
	Type   string              `yaml:"type"`
	Size   int                 `yaml:"size"`
	Labels map[string][]string `yaml:"labels"`
}

func Parse(buf []byte) (*Config, error) {
	var c Config
	if err := yaml.Unmarshal(buf, &c); err != nil {
		return nil, err
	}
	return &c, nil
}
