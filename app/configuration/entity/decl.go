package entity

import "regexp"

const (
	localhost = "127.0.0.1"
	maxPort   = 65536
)

var (
	regSpaces = regexp.MustCompile(`\s+`)
)
