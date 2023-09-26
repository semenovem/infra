package main

import (
	"flag"
	"fmt"
	"github.com/joho/godotenv"
	"os"
	"strconv"

	"github.com/caarlos0/env"
)

const (
	debugEnvName = "IP_ECHO_DEBUG"
	PortEnvName  = "IP_ECHO_PORT"

	boolErrMsgTmpl = "invalid value of environment variable %s=%s. Can be one of [false|true|0|1]"

	defaultConfigFile = "/etc/ipecho/config.env"
)

var (
	config = mainConfig{}
)

type mainConfig struct {
	Port  uint `env:"PORT,required"`
	Debug bool `env:"DEBUG"`
}

func init() {
	// File with env config
	envFile := ""
	flag.StringVar(&envFile, "env", defaultConfigFile, "env for use")
	flag.Parse()

	if envFile != "" {
		logDebug("init.env is used %s", envFile)
		if err := godotenv.Load(envFile); err != nil {
			logDebug("init.godotenv.Load: %s", err.Error())
			os.Exit(-1)
		}

		if err := env.Parse(&config); err != nil {
			logErr("init.env.Parse: %s", err.Error())
			os.Exit(1)
		}

	}

	// Environment
	if v := os.Getenv(debugEnvName); v != "" {
		if b, err := strconv.ParseBool(v); err != nil {
			logErr(boolErrMsgTmpl, debugEnvName, v)
		} else {
			config.Debug = b
		}
	}

	if v := os.Getenv(PortEnvName); v != "" {
		if port, err := strconv.ParseUint(v, 10, 32); err != nil {
			logErr(
				"Invalid value of environment variable %s=%s. Can be int",
				PortEnvName, v)
		} else {
			config.Port = uint(port)
		}
	}

	fmt.Printf("[INFO] DEBUG = %v\n", config.Debug)
	fmt.Printf("[INFO] PORT = %d\n", config.Port)
}

func logErr(msg string, v ...any) {
	fmt.Printf("[ERRO] "+msg, v...)
	fmt.Println()
}

func logDebug(msg string, v ...any) {
	if config.Debug {
		fmt.Printf("[DEBU] "+msg, v...)
		fmt.Println()
	}
}
