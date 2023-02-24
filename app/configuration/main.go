package main

import (
	"configuration/tasks"
	"errors"
	"flag"
	"log"
	"os"
	"syscall"
)

// go run main.go  -config-file=fgfg/sdfdf.conf verify

var (
	loggerErr   = log.New(os.Stderr, "[ERRO] ", 0)
	loggerInfo  = log.New(os.Stdout, "", 0)
	loggerDebug = log.New(os.Stderr, "[DEBU] ", 0)
)

func init() {
	tasks.SetLoggers(loggerInfo, loggerDebug)
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		loggerErr.Println(err)
		syscall.Exit(1)
	}

	os.Exit(0)
}

func run(args []string) error {
	if len(args) == 0 {
		tasks.Help()
		return nil
	}

	for _, task := range tasks.New() {
		if task.Name() != args[0] {
			continue
		}

		if err := task.Init(args[1:]); err != nil {
			if errors.Is(err, flag.ErrHelp) {
				task.Help()
				return nil
			}

			return err
		}

		return task.Run()
	}

	// Проверить версию и

	return errors.New("main.run: нет команды")
}
