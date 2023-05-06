package entity

import (
	"fmt"
	"strconv"
	"strings"
)

type SSHPortForward struct {
	Host     string
	User     string
	Port     uint16
	Forwards []*SSHForward
}

func (c *SSHPortForward) FormatRemote() string {
	out := make([]string, 0)

	if c.User != "" {
		out = append(out, c.User, "@")
	}

	out = append(out, c.Host)

	if c.Port != 0 {
		out = append(out, " -p "+strconv.Itoa(int(c.Port)))
	}

	forwards := make([]string, len(c.Forwards))

	for i, v := range c.Forwards {
		forwards[i] = v.FormatRemote()
	}

	out = append(out, " "+strings.Join(forwards, " "))

	return strings.Join(out, "")
}

// ParseSSHConnForward
// remote2-user@host.site.dom -p 2022 2201::22 11941:0.0.0.0:1194
// remote3-user@msk1 2201::22 11941:0.0.0.0:1194
// user@host.dom -p 2022 2201::22 11941:0.0.0.0:1194
// msk1 2201::22 11941:0.0.0.0:1194
// remote@msk1 2201::22 11941:0.0.0.0:1194
func ParseSSHConnForward(s string) (*SSHPortForward, error) {
	var (
		elems       = strings.Fields(s)
		connForward = &SSHPortForward{
			Forwards: make([]*SSHForward, 0),
		}
		hasPort bool
		err     error
	)

	if len(elems) < 1 {
		return nil, fmt.Errorf("не корректный формат [%s]", s)
	}

	if strings.Contains(elems[0], "@") {
		userHost := split(elems[0], "@")

		if len(userHost) != 2 {
			return nil, fmt.Errorf("не корректный формат user@host в [%s]", s)
		}

		connForward.User = userHost[0]
		connForward.Host = userHost[1]
	} else {
		connForward.Host = elems[0]
	}

	elems = elems[1:]

	for i := 0; i < len(elems); i++ {
		v := elems[i]

		if v == "-p" {
			if hasPort {
				return nil, fmt.Errorf("дубликат флага -p [%s]", s)
			}

			hasPort = true
			i++

			if i >= len(elems) {
				return nil, fmt.Errorf("нет значения для флага -p [%s]", s)
			}

			connForward.Port, err = ParsePort(elems[i])
			if err != nil {
				return nil, fmt.Errorf("ошибка при приведении значения флага -p к числу [%s]", s)
			}

			continue
		}

		it, err := ParseSSHForward(v)
		if err != nil {
			return nil, err
		}

		connForward.Forwards = append(connForward.Forwards, it)
	}

	if len(connForward.Forwards) == 0 {
		return nil, fmt.Errorf("не корректный формат [%s]. Нет данных для проброса", s)
	}

	return connForward, nil
}
