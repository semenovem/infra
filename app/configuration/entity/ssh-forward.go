package entity

import (
	"fmt"
	"strings"
)

type SSHForward struct {
	port1 uint16
	host  string
	port2 uint16
}

func (o *SSHForward) FormatRemote() string {
	return fmt.Sprintf("%d:%s:%d", o.port1, o.GetHost(), o.port2)
}

func (o *SSHForward) FormatLocal() string {
	return fmt.Sprintf("%d:%s:%d", o.port2, o.GetHost(), o.port1)
}

func (o *SSHForward) GetHost() string {
	if o.host != "" {
		return o.host
	}

	return localhost
}

func (o *SSHForward) Port1() uint16 {
	return o.port1
}

func (o *SSHForward) Port2() uint16 {
	return o.port2
}

// ParseSSHForward
// 2201::22
// 11941:0.0.0.0:1194
// 2201:localhost:22
func ParseSSHForward(s string) (*SSHForward, error) {
	var (
		frwd  = &SSHForward{}
		err   error
		items = CompressArr(strings.Split(RemoveSpaces(s), ":"))
	)

	if len(items) < 2 || len(items) > 3 || strings.Count(s, ":") > 2 {
		return nil, fmt.Errorf("не верный формат SSHForward port:host:port. [%s]", s)
	}

	if frwd.port1, err = ParsePort(items[0]); err != nil {
		return nil, fmt.Errorf("ошибка парсинга строки [%s] в SSHForwad: %s", s, err)
	}

	if frwd.port2, err = ParsePort(items[len(items)-1]); err != nil {
		return nil, fmt.Errorf("ошибка парсинга строки [%s] в SSHForwad: %s", s, err)
	}

	if len(items) == 3 {
		frwd.host = items[1]
	}

	return frwd, nil
}
