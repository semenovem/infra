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

func Test_parsePort(t *testing.T) {
	t.Parallel()

	t.Run("отрицательные числа", func(t *testing.T) {
		p, err := parsePort("-1")
		if !assert.Error(t, err) {
			return
		}
		assert.EqualValues(t, 0, p)
	})

	t.Run("выходит за допустимый диапазон", func(t *testing.T) {
		p, err := parsePort("2341234124")
		if !assert.Error(t, err) {
			return
		}
		assert.EqualValues(t, 0, p)
	})

	t.Run("ok", func(t *testing.T) {
		p, err := parsePort("12334")
		if !assert.NoError(t, err) {
			return
		}
		assert.EqualValues(t, 12334, p)
	})

}
