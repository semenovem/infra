package configs

import (
	"fmt"
	"strings"
)

func (o *SSHRemoteForward) GetItems() (map[string][]string, error) {
	hostMap := make(map[string][]string)

	for _, port := range o.PortsRaw {
		hosts, forward, err := parseSSHLocalForward(port)
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

			hostMap[host] = append(hostMap[host], forward.format())
		}
	}

	return hostMap, nil
}

type sshForward struct {
	port     string
	host     string
	hostPort string
}

func (o *sshForward) format() string {
	return fmt.Sprintf("%s:%s:%s", o.port, o.host, o.hostPort)
}

func parseSSHLocalForward(p string) (hosts []string, forward *sshForward, err error) {
	forward = &sshForward{}
	hosts = make([]string, 0)

	var (
		hostMap  = make(map[string]struct{})
		errValid = fmt.Errorf("strings.parseSSHLocalForward: не вадидное значение [%s]", p)
		raw      = strings.Split(p, ":")
	)

	trim(raw)

	if len(raw) < 3 {
		return nil, nil, errValid
	}

	forward.port = raw[0]
	forward.host = raw[1]
	if forward.host == "" {
		forward.host = "127.0.0.1"
	}

	additional := strings.Fields(raw[2])
	forward.hostPort = additional[0]

	for _, v := range additional[1:] {
		vv := normalizeHostName(v)
		if vv != "" {
			hostMap[vv] = struct{}{}
		}
	}

	for k, _ := range hostMap {
		hosts = append(hosts, k)
	}

	return
}
