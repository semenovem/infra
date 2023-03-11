package configs

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestGetExistingRoles(t *testing.T) {
	t.Parallel()

	t.Run("ok", func(t *testing.T) {
		c := Config{
			Roles: []*Role{
				{Name: "123"},
				{Name: "qwe"},
				{Name: "asd"},
			},
		}

		roles, err := c.GetExistingRoles()
		if !assert.NoError(t, err) {
			return
		}

		expected := map[string]*Role{
			"123": {Name: "123"},
			"qwe": {Name: "qwe"},
			"asd": {Name: "asd"},
		}

		assert.Equal(t, expected, roles)
	})

	t.Run("duplicate", func(t *testing.T) {
		c := Config{
			Roles: []*Role{
				{Name: "123"},
				{Name: "123"},
			},
		}

		roles, err := c.GetExistingRoles()

		if !assert.Error(t, err) {
			return
		}

		assert.Nil(t, roles)
	})

	t.Run("duplicate2", func(t *testing.T) {
		c := Config{
			Roles: []*Role{
				{Name: "qwe"},
				{Name: "QWE"},
			},
		}

		roles, err := c.GetExistingRoles()

		if !assert.Error(t, err) {
			return
		}

		assert.Nil(t, roles)
	})
}
