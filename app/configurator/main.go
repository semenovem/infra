package main

import (
	"configuration/cmd"
	"errors"
	"flag"
	"io"
	"log"
	"os"
)

// go run main.go  -config-file=fgfg/sdfdf.conf verify

var (
	loggerErr   = log.New(os.Stderr, "[ERRO] ", 0)
	loggerInfo  = log.New(os.Stdout, "", 0)
	loggerDebug = log.New(os.Stderr, "[DEBU] ", 0)
	appVersion  = ""
)

func getAppVersion() string {
	return appVersion
}

func init() {
	cmd.GetAppVersion = getAppVersion
	loggerDebug.SetOutput(io.Discard)
	cmd.SetLoggers(loggerInfo, loggerDebug)
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		os.Exit(1)
	}

	os.Exit(0)
}

func run(args []string) error {
	if len(args) == 0 {
		cmd.Help()
		return nil
	}

	for _, task := range cmd.New() {
		if task.Name() != args[0] {
			continue
		}

		err := func() error {
			if err := task.Init(args[1:]); err != nil {
				return err
			}

			return task.Run()
		}()

		if err != nil {
			if errors.Is(err, flag.ErrHelp) {
				task.Help()
				return nil
			}

			loggerErr.Println(err)
		}

		return err
	}

	err := errors.New("main.run: не валидные аргументы")
	loggerErr.Println(err.Error())

	cmd.ShortHelp()

	return err
}
