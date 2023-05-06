package entity

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestParseSSHForward(t *testing.T) {
	t.Parallel()

	cases := map[string]*SSHForward{
		"32231:0.0.0.0:1212":  {port1: 32231, host: "0.0.0.0", port2: 1212},
		"11941::1194":         {port1: 11941, host: "", port2: 1194},
		"11941:site.com:1194": {port1: 11941, host: "site.com", port2: 1194},
		" 11941 :  : 1194 ":   {port1: 11941, host: "", port2: 1194},
		"2200:::1194":         nil,
		"::1194":              nil,
		"1194":                nil,
		"":                    nil,
	}

	t.Run("2", func(t *testing.T) {
		for str, expect := range cases {
			res, err := ParseSSHForward(str)

			if expect == nil {
				assert.Error(t, err, "ошибка при парсинге строки: {%s}", str)
				continue
			}

			if !assert.NoError(t, err, "ошибка при парсинге строки: {%s}", str) {
				continue
			}

			assert.Equal(t, expect, res)
		}
	})
}
