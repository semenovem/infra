package configs

import (
	"strings"
)

type Config struct {
	Version         string           `yaml:"version"`
	Hosts           []*Host          `yaml:"hosts"`
	Roles           []*Role          `yaml:"roles"`
	SSHLocalForward *SSHLocalForward `yaml:"ssh_local_forward"`
}

type Host struct {
	Name            string           `yaml:"name"`
	Role            string           `yaml:"role"`
	Description     string           `yaml:"description,omitempty"`
	Crontab         string           `yaml:"crontab,omitempty"`
	Public          *URL             `yaml:"public,omitempty"`
	Local           *URL             `yaml:"local,omitempty"`
	SSH             *SSH             `yaml:"ssh,omitempty"`
	SSHLocalForward *SSHLocalForward `yaml:"ssh_local_forward,omitempty"`
}

type URL struct {
	URL  string `yaml:"url,omitempty"`
	IP   string `yaml:"ip,omitempty"`
	IPv6 string `yaml:"ipv6,omitempty"`
}

type SSH struct {
	Port   int      `yaml:"port,omitempty"`
	Main   *SSHUser `yaml:"main,omitempty"`
	Remote *SSHUser `yaml:"remote,omitempty"`
}

type SSHUser struct {
	User   string `yaml:"user"`
	PubKey string `yaml:"pub_key"`
}

type Role struct {
	Name                        string `yaml:"name,omitempty"`
	AllowIncomingSSHForRolesRaw string `yaml:"allow_incoming_ssh_for_roles,omitempty"`
}

type SSHLocalForward struct {
	HostsRaw string   `yaml:"hosts,omitempty"`
	PortsRaw []string `yaml:"ports,omitempty"`
}

func (o Role) AllowIncomingSSHForRoles() []string {
	return split(o.AllowIncomingSSHForRolesRaw)
}

func (o *SSHLocalForward) Hosts() []string {
	return split(o.HostsRaw)
}

func split(s string) []string {
	return strings.Fields(s)
}

func (h *Host) GetMainPubKeyBySSHUserName() string {
	if h.SSH != nil && h.SSH.Main != nil {
		return h.SSH.Main.PubKey
	}

	return ""
}
