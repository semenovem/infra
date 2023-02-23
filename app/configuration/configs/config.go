package configs

type Config struct {
	CPIs           []*CPI          `yaml:"cpi"`
	Roles          []*Role         `yaml:"roles"`
	PortForwarding *PortForwarding `yaml:"port_forwarding"`
}

type CPI struct {
	RolesRaw string `yaml:"roles"`
	Roles    string `yaml:"roles_array"`
	Host     string `yaml:"host"`
	Public   *URL   `yaml:"public"`
	Local    *URL   `yaml:"local"`
	SSH      *SSH   `yaml:"ssh"`
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
	Name                string   `yaml:"name"`
	AllowIncomingSSHRaw string   `yaml:"allow_incoming_ssh"`
	AllowIncomingSSH    []string `yaml:"allow_incoming_ssh_array"`
}

type PortForwarding struct {
	ProxiesRaw string   `yaml:"proxies"`
	Proxies    []string `yaml:"proxies_array"`
	Ports      []string `yaml:"ports"`
}
