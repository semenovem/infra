package entity

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestParseSSHConnForward(t *testing.T) {
	t.Parallel()

	cases := map[string]*SSHPortForward{
		"msk1 3434::34343": {
			Host: "msk1",
			User: "",
			Port: 0,
			Forwards: []*SSHForward{
				{
					port1: 3434,
					host:  "",
					port2: 34343,
				},
			},
		},
		"site.com -p 3000 3432:localhost:34341": {
			Host: "site.com",
			User: "",
			Port: 3000,
			Forwards: []*SSHForward{
				{
					port1: 3432,
					host:  "localhost",
					port2: 34341,
				},
			},
		},
		"user@site.com -p 3000 3432:localhost:34341 6767::8080": {
			Host: "site.com",
			User: "user",
			Port: 3000,
			Forwards: []*SSHForward{
				{
					port1: 3432,
					host:  "localhost",
					port2: 34341,
				},
				{
					port1: 6767,
					host:  "",
					port2: 8080,
				},
			},
		},
		"site.com -p 3001":         nil,
		"site.com -p 3001 -p 5000": nil,
		"site.com":                 nil,
		"":                         nil,
	}

	for str, expect := range cases {
		res, err := ParseSSHConnForward(str)

		if expect == nil {
			assert.Error(t, err, "ошибка парсинга строки: {%s}", str)
			continue
		}

		if !assert.NoError(t, err, "ошибка парсинга строки: {%s}", str) {
			continue
		}

		assert.Equal(t, expect, res)
	}
}
