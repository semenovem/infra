package entity

import (
	"fmt"
	"strconv"
	"strings"
)

func trim(a []string) {
	for i := 0; i < len(a); i++ {
		a[i] = strings.TrimSpace(a[i])
	}
}

func split(s, sep string) []string {
	a := strings.Split(s, sep)
	trim(a)

	return a
}

func ParsePort(s string) (uint16, error) {
	port, err := strconv.ParseUint(s, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("ошибка парсинга числа [%s] в порт: %s", s, err)
	}

	if port > maxPort {
		return 0, fmt.Errorf("значение port [%d] превышает максимальное [%d]", port, maxPort)
	}

	return uint16(port), nil
}

func RemoveSpaces(s string) string {
	return regSpaces.ReplaceAllString(s, "")
}

func CompressArr(s []string) []string {
	i2 := -1

	for i := 0; i < len(s); i++ {
		if s[i] == "" {
			if i2 == -1 {
				i2 = i
			}

			continue
		}

		if i2 != -1 {
			s[i2] = s[i]
			i2++
		}
	}

	if i2 == -1 {
		return s
	}

	return s[:i2]
}
