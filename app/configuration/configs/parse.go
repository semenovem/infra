package configs

import (
	"fmt"
	"os"
	"strings"

	"gopkg.in/yaml.v3"
)

func ParseConfigFile(fileName string) (*Config, error) {
	var cfg Config

	bytes, err := os.ReadFile(fileName)
	if err != nil {
		return nil, fmt.Errorf("Error reading YAML file: %s\n", err.Error())
	}

	err = yaml.Unmarshal(bytes, &cfg)
	if err != nil {
		return nil, fmt.Errorf("Error parsing YAML file: %s\n", err.Error())
	}

	hostsFiltered := make([]*Host, 0)
	for _, cpi := range cfg.Hosts {
		if !strings.EqualFold(cpi.Name, "example") {
			hostsFiltered = append(hostsFiltered, cpi)
		}
	}
	cfg.Hosts = hostsFiltered

	rolesFiltered := make([]*Role, 0)
	for _, role := range cfg.Roles {
		if !strings.EqualFold(role.Name, "example") {
			rolesFiltered = append(rolesFiltered, role)
		}
	}
	cfg.Roles = rolesFiltered

	return &cfg, nil
}
