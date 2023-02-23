package configs

import (
	"fmt"
	"gopkg.in/yaml.v3"
	"os"
	"strings"
)

func ParseConfigFile(fileName string) (*Config, error) {
	var cfg Config

	bytes, err := os.ReadFile(fileName)
	if err != nil {
		return nil, fmt.Errorf("Error reading YAML file: %s\n", err)
	}

	err = yaml.Unmarshal(bytes, &cfg)
	if err != nil {
		return nil, fmt.Errorf("Error parsing YAML file: %s\n", err)
	}

	cpisFiltered := make([]*CPI, 0)
	for _, cpi := range cfg.CPIs {
		if !strings.EqualFold(cpi.Host, "example") {
			cpisFiltered = append(cpisFiltered, cpi)
		}
	}
	cfg.CPIs = cpisFiltered

	rolesFiltered := make([]*Role, 0)
	for _, role := range cfg.Roles {
		if !strings.EqualFold(role.Name, "example") {
			rolesFiltered = append(rolesFiltered, role)
		}
	}
	cfg.Roles = rolesFiltered

	return &cfg, nil
}
