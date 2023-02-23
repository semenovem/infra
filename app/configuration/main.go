package main

import (
	"log"
	"os"
)

// go run main.go  -config-file=fgfg/sdfdf.conf verify

var (
	logger      = log.New(os.Stdout, "[INFO] ", 0)
	loggerErr   = log.New(os.Stderr, "[ERRO] ", 0)
	loggerDebug = log.New(os.Stderr, "[DEBU] ", 0)
)

func main() {
	var err error

	if err = parseArgs(os.Args[1:]); err != nil {
		loggerErr.Println(err.Error())
		os.Exit(1)
	}

	os.Exit(0)
}
