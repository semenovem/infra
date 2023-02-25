package configs

import (
	"regexp"
	"strings"
)

var regHostName = regexp.MustCompile(`\W`)

func normalizeHostName(s string) string {
	return regHostName.ReplaceAllString(s, "")
}

func trim(a []string) {
	for i := 0; i < len(a); i++ {
		a[i] = strings.TrimSpace(a[i])
	}
}

func flatten(a []string) []string {
	b := make([]string, 0)

	for _, v := range a {
		if v != "" {
			b = append(b, v)
		}
	}

	return b
}

func arrToMap(arr []string) map[string]struct{} {
	m := make(map[string]struct{})
	for _, v := range arr {
		m[v] = struct{}{}
	}
	return m
}
