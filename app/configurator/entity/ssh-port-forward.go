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
		forwards[i] = "-R " + v.FormatRemote()
	}

	out = append(out, " "+strings.Join(forwards, " "))

	return strings.Join(out, "")
}

func ParseSSHConnForwards(ls []string) ([]*SSHPortForward, error) {
	if len(ls) == 0 {
		return nil, nil
	}

	var (
		ret = make([]*SSHPortForward, len(ls))
		err error
	)

	for i, v := range ls {
		if ret[i], err = ParseSSHConnForward(v); err != nil {
			return nil, err
		}
	}

	return ret, nil
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

	if connForward.User, connForward.Host, err = ParseConn(elems[0]); err != nil {
		return nil, err
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

func ParseConn(str string) (user, host string, err error) {
	s := RemoveSpaces(str)

	if strings.Contains(s, "@") {
		userHost := split(s, "@")

		if len(userHost) != 2 {
			err = fmt.Errorf("не корректный формат user@host в [%s]", str)
			return
		}

		user = userHost[0]
		host = userHost[1]
	} else {
		host = s
	}

	if host == "" {
		user = ""
		err = fmt.Errorf("не корректный формат user@host в [%s]", str)
	}

	return
}
