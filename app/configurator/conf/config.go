package conf

import (
	"configuration/entity"
	"strings"
)

// Config
// -----------------------------------------------------------------------------
type Config struct {
	Version string     `yaml:"version"`
	Hosts   []*DTOHost `yaml:"hosts"`
	Roles   []*DTORole `yaml:"roles"`
}

func (c *Config) getMapOfHosts() map[string]*DTOHost {
	m := make(map[string]*DTOHost)

	for _, host := range c.Hosts {
		m[host.Name] = host
	}

	return m
}

func (c *Config) getHostSSHPortForward(n string) (*DTOSSHPortForward, error) {
	thisHost, err := c.GetHost(n)
	if err != nil {
		return nil, err
	}

	return thisHost.SSHPortForward, nil
}

func (c *Config) getHostSSH(n string) (*DTOSSH, error) {
	thisHost, err := c.GetHost(n)
	if err != nil {
		return nil, err
	}

	return thisHost.SSH, nil
}

// DTOHost
// -----------------------------------------------------------------------------
type DTOHost struct {
	Name           string             `yaml:"name"`
	Role           string             `yaml:"role"`
	Description    string             `yaml:"description,omitempty"`
	Crontab        string             `yaml:"crontab,omitempty"`
	Public         *DTOConn           `yaml:"public,omitempty"`
	Local          *DTOConn           `yaml:"local,omitempty"`
	SSH            *DTOSSH            `yaml:"ssh,omitempty"`
	SSHPortForward *DTOSSHPortForward `yaml:"ssh_remote_forward,omitempty"`
}

func (h *DTOHost) getMainPubKeyBySSHUserName() string {
	if h.SSH != nil && h.SSH.Main != nil {
		return h.SSH.Main.PubKey
	}

	return ""
}

func (h *DTOHost) getSSHPublicURLOrIP() string {
	if h.Public == nil {
		return ""
	}

	if h.Public.URL != "" {
		return h.Public.URL
	}

	return h.Public.IP
}

// DTORole
// -----------------------------------------------------------------------------
type DTORole struct {
	Name                        string `yaml:"name,omitempty"`
	AllowIncomingSSHForRolesRaw string `yaml:"allow_incoming_ssh_for_roles,omitempty"`
}

func (o DTORole) allowIncomingSSHForRoles() []string {
	return strings.Fields(o.AllowIncomingSSHForRolesRaw)
}

// DTOConn
// -----------------------------------------------------------------------------
type DTOConn struct {
	URL  string `yaml:"url,omitempty"`
	IP   string `yaml:"ip,omitempty"`
	IPv6 string `yaml:"ipv6,omitempty"`
}

// DTOSSH
// -----------------------------------------------------------------------------
type DTOSSH struct {
	Port   uint16      `yaml:"port,omitempty"`
	Main   *DTOSSHUser `yaml:"main,omitempty"`
	Remote *DTOSSHUser `yaml:"remote,omitempty"`
}

func (o *DTOSSH) getMainUser() string {
	if o.Main != nil {
		return o.Main.User
	}

	return ""
}

// DTOSSHPortForward
// -----------------------------------------------------------------------------
type DTOSSHPortForward struct {
	User      string   `yaml:"user,omitempty"`
	Hosts     string   `yaml:"hosts,omitempty"`      // msk1 rr1 rr4
	Ports     []string `yaml:"ports,omitempty"`      // - 31194::1194 \n -31194:0.0.0.0:1194
	ConnectTo []string `yaml:"connect_to,omitempty"` // user@host.dom -p 2022 2201::22 11941:0.0.0.0:1194
}

func (o *DTOSSHPortForward) getHosts() []string {
	return strings.Fields(o.Hosts)
}

func (o *DTOSSHPortForward) getForward() ([]*entity.SSHForward, error) {
	return entity.ParseSSHForwards(o.Ports)
}

// getConnections возвращает данные для проброса портов
func (o *DTOSSHPortForward) getConnections() ([]*entity.SSHPortForward, error) {
	return entity.ParseSSHConnForwards(o.ConnectTo)
}

// getConnections возвращает данные для проброса портов
func (o *DTOSSHPortForward) getConvertHosts() ([]*entity.SSHPortForward, error) {
	var (
		ret = make([]*entity.SSHPortForward, 0)
	)

	forward, err := o.getForward()
	if err != nil {
		return nil, err
	}

	for _, v := range o.getHosts() {
		it := &entity.SSHPortForward{}
		if it.User, it.Host, err = entity.ParseConn(v); err != nil {
			return nil, err
		}

		it.Forwards = forward

		ret = append(ret, it)
	}

	return ret, nil
}
