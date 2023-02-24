package configs

import "strings"

type Config struct {
	CPIs           []*CPI          `yaml:"cpi"`
	Roles          []*Role         `yaml:"roles"`
	PortForwarding *PortForwarding `yaml:"port_forwarding"`
}

type CPI struct {
	RolesRaw string `yaml:"roles"`
	Host     string `yaml:"host"`
	Public   *URL   `yaml:"public"`
	Local    *URL   `yaml:"local"`
	SSH      *SSH   `yaml:"ssh"`
}

func (o CPI) Roles() []string {
	return split(o.RolesRaw)
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
	Name                string `yaml:"name"`
	AllowIncomingSSHRaw string `yaml:"allow_incoming_ssh"`
}

func (o Role) AllowIncomingSSH() []string {
	return split(o.AllowIncomingSSHRaw)
}

type PortForwarding struct {
	ProxiesRaw string   `yaml:"proxies"`
	Ports      []string `yaml:"ports"`
}

func (o PortForwarding) Proxies() []string {
	return split(o.ProxiesRaw)
}

func split(s string) []string {
	return strings.Split(s, " ")
}
