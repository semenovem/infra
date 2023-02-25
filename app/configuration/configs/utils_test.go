package configs

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func Test_normalizeHostName(t *testing.T) {
	t.Parallel()

	t.Run("1", func(t *testing.T) {
		cases := map[string]string{
			"1212":                   "1212",
			"qwqwqw":                 "qwqwqw",
			"1212qwqw":               "1212qwqw",
			"1212 qwqw":              "1212qwqw",
			"1212.!@#$%^&*()+-+qwqw": "1212qwqw",
		}

		for raw, expect := range cases {
			assert.Equal(t, expect, normalizeHostName(raw))
		}
	})
}
