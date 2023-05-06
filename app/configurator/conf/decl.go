package conf

import (
	"fmt"
	"gopkg.in/yaml.v3"
	"os"
	"strings"
)

var (
	errDuplicateRoleMsg = "root/Roles contains duplicate role [%s]"
	errRoleExistsMsg    = "role [%s] does not exist"

	localhost = "127.0.0.1"

	sshPort = uint16(22)
)

type DTOSSHUser struct {
	User   string `yaml:"user"`
	PubKey string `yaml:"pub_key"`
}

type Err struct {
	msg        string
	isNotFound bool
}

func (e Err) Error() string {
	return e.msg
}

func NewErrNotFound(msg string, args ...interface{}) *Err {
	if len(args) != 0 {
		msg = fmt.Sprintf(msg, args...)
	}

	return &Err{msg: msg, isNotFound: true}
}

func IsErrNotFound(err error) bool {
	if e, ok := err.(Err); ok {
		return e.isNotFound
	}

	return false
}

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

	hostsFiltered := make([]*DTOHost, 0)
	for _, cpi := range cfg.Hosts {
		if !strings.EqualFold(cpi.Name, "example") {
			hostsFiltered = append(hostsFiltered, cpi)
		}
	}
	cfg.Hosts = hostsFiltered

	rolesFiltered := make([]*DTORole, 0)
	for _, role := range cfg.Roles {
		if !strings.EqualFold(role.Name, "example") {
			rolesFiltered = append(rolesFiltered, role)
		}
	}
	cfg.Roles = rolesFiltered

	return &cfg, nil
}
