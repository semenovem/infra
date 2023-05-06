package entity

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestCompressArr(t *testing.T) {
	t.Parallel()

	cases := []struct {
		in  []string
		out []string
	}{
		{
			in:  []string{"1", "2", "3"},
			out: []string{"1", "2", "3"},
		},
		{
			in:  []string{"", "1", "2", "3"},
			out: []string{"1", "2", "3"},
		},
		{
			in:  []string{"1", "2", "", "3"},
			out: []string{"1", "2", "3"},
		},
		{
			in:  []string{"1", "2", "", "3", ""},
			out: []string{"1", "2", "3"},
		},
	}

	for _, c := range cases {
		assert.Equal(t, c.out, CompressArr(c.in))
	}
}
