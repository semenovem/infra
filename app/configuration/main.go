package main

import (
	"configuration/tasks"
	"errors"
	"flag"
	"log"
	"os"
)

// go run main.go  -config-file=fgfg/sdfdf.conf verify

var (
	logger      = log.New(os.Stdout, "[INFO] ", 0)
	loggerErr   = log.New(os.Stderr, "[ERRO] ", 0)
	loggerDebug = log.New(os.Stderr, "[DEBU] ", 0)
)

func init() {
	tasks.SetLoggers(loggerErr, logger, loggerDebug)
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		os.Exit(1)
	}

	os.Exit(0)
}

func run(args []string) error {
	if len(args) == 0 {
		return errors.New("нет аргументов")
	}

	for _, task := range tasks.New() {
		if task.Name() == args[0] {
			if err := task.Init(args[1:]); err != nil {
				if errors.Is(err, flag.ErrHelp) {
					task.Help()
					return nil
				}

				return err
			}

			return task.Run()
		}
	}

	return errors.New("нет команды")
}
