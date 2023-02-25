package configs

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func Test_parseSSHLocalForward(t *testing.T) {
	t.Parallel()

	t.Run("1", func(t *testing.T) {
		hosts, forward, err := parseSSHLocalForward("20022 : 0.0.0.0:22 (msk1, rr1)")
		if !assert.NoError(t, err) {
			return
		}

		assert.Equal(t, []string{"msk1", "rr1"}, hosts)
		assert.Equal(t, forward.port, "20022")
		assert.Equal(t, forward.host, "0.0.0.0")
		assert.Equal(t, forward.hostPort, "22")
	})

	t.Run("2", func(t *testing.T) {
		hosts, forward, err := parseSSHLocalForward("20022 :  :22 (msk1, rr1)")
		if !assert.NoError(t, err) {
			return
		}

		assert.ElementsMatch(t, []string{"msk1", "rr1"}, hosts)
		assert.Equal(t, forward.port, "20022")
		assert.Equal(t, forward.host, "127.0.0.1")
		assert.Equal(t, forward.hostPort, "22")
	})

}
