package configs

import (
	"strings"
)

type Config struct {
	Version        string          `yaml:"version"`
	Hosts          []*Host         `yaml:"hosts"`
	Roles          []*Role         `yaml:"roles"`
	PortForwarding *PortForwarding `yaml:"port_forwarding"`
}

type Host struct {
	Role           string          `yaml:"role"`
	Name           string          `yaml:"name"`
	Public         *URL            `yaml:"public"`
	Local          *URL            `yaml:"local"`
	SSH            *SSH            `yaml:"ssh"`
	PortForwarding *PortForwarding `yaml:"port_forwarding"`
}

type URL struct {
	URL  string `yaml:"url"`
	IP   string `yaml:"ip"`
	IPv6 string `yaml:"ipv6"`
}

type SSH struct {
	Port   int      `yaml:"port"`
	Main   *SSHUser `yaml:"main"`
	Remote *SSHUser `yaml:"remote"`
}

type SSHUser struct {
	User   string `yaml:"user"`
	PubKey string `yaml:"pub_key"`
}

type Role struct {
	Name                        string `yaml:"name"`
	AllowIncomingSSHForRolesRaw string `yaml:"allow_incoming_ssh_for_roles"`
}

func (o Role) AllowIncomingSSHForRoles() []string {
	return split(o.AllowIncomingSSHForRolesRaw)
}

type PortForwarding struct {
	HostsRaw string   `yaml:"hosts"`
	Ports    []string `yaml:"ports"`
}

func (o PortForwarding) Hosts() []string {
	return split(o.HostsRaw)
}

func split(s string) []string {
	return strings.Split(s, " ")
}

func (h *Host) GetMainPubKeyBySSHUserName() string {
	if h.SSH != nil && h.SSH.Main != nil {
		return h.SSH.Main.PubKey
	}

	return ""
}
