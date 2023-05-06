package configs

import "strings"

type DTOSSHPortForward struct {
	User      string   `yaml:"user,omitempty"`
	HostsRaw  string   `yaml:"hosts,omitempty"`      // msk1 rr1 rr4
	PortsRaw  []string `yaml:"ports,omitempty"`      // - 31194::1194 \n -31194:0.0.0.0:1194
	ConnectTo []string `yaml:"connect_to,omitempty"` // user@host.dom -p 2022 2201::22 11941:0.0.0.0:1194
}

func (o *DTOSSHPortForward) Hosts() []string {
	return strings.Fields(o.HostsRaw)
}

func (o *DTOSSHPortForward) getUser() string {
	return o.User
}

func (o *DTOSSHPortForward) GetItems() (map[string][]string, error) {
	hostMap := make(map[string][]string)

	for _, port := range o.PortsRaw {
		hosts, forward, err := parseSSHForward(port)
		if err != nil {
			return nil, err
		}

		if len(hosts) == 0 {
			hosts = o.Hosts()
		}

		for host, _ := range arrToMap(hosts) {
			if _, ok := hostMap[host]; !ok {
				hostMap[host] = make([]string, 0)
			}

			hostMap[host] = append(hostMap[host], forward.formatRemote())
		}
	}

	return hostMap, nil
}

func (o *DTOSSHPortForward) getConnectTo() ([]*SSHConnForward, error) {
	forwards := make([]*SSHConnForward, 0)

	for _, v := range o.ConnectTo {
		frwd, err := parseConnectTo(v)
		if err != nil {
			return nil, err
		}

		forwards = append(forwards, frwd)
	}

	return forwards, nil
}
