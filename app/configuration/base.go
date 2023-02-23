package main

import (
	"configuration/configs"
	"errors"
	"flag"
	"fmt"
	"gopkg.in/yaml.v3"
	"io"
)

const (
	configFileArgUsage = "# файл конфигурации"
	verifyCmdArgUsage  = "# валидация файла"
	debugArgUsage      = "# отладочный вывод"

	debugArgName      = "debug"
	configFileArgName = "config-file"
)

type task interface {
	Init([]string) error
	Run() error
	Name() string
}

var tasks = []task{
	&verifyTask{base{name: "verify", adds: adds(addConfigFileArgs)}},
	&verifyTask{},
}

func adds(a ...func(*flag.FlagSet)) []func(*flag.FlagSet) {
	return a
}

func parseArgs(args []string) error {
	if len(args) == 0 {
		return errors.New("нет аргументов")
	}

	for _, task := range tasks {
		if task.Name() == args[0] {
			if err := task.Init(args[1:]); err != nil {
				return err
			}

			return task.Run()
		}
	}

	return errors.New("нет команды")
}

type base struct {
	fs      *flag.FlagSet
	isDebug bool
	name    string
	adds    []func(*flag.FlagSet)
}

func (t *base) Name() string {
	return t.name
}

func (t *base) Init(args []string) error {
	t.fs = flag.NewFlagSet(t.name, flag.ContinueOnError)
	t.fs.SetOutput(io.Discard)
	t.fs.BoolVar(&t.isDebug, debugArgName, false, debugArgUsage)

	for _, f := range t.adds {
		f(t.fs)
	}

	err := t.fs.Parse(args)
	if err != nil {
		logger.Println("ERROR:")
		t.fs.VisitAll(func(f *flag.Flag) {
			logger.Println(">>>> ", f.Name, " = ", f.Value)
		})
	} else if t.isDebug {
		logger.Println("DEBUG:")
		t.fs.VisitAll(func(f *flag.Flag) {
			loggerDebug.Printf("%s=%s", f.Name, f.Value)
		})
	}

	return err
}

func (t *base) getConfigFile() (*configs.Config, error) {
	fileName := t.fs.Lookup(configFileArgName).Value.String()

	config, err := configs.ParseConfigFile(fileName)
	if err != nil {
		return nil, err
	}

	// TODO для отладки
	p, _ := yaml.Marshal(config)
	fmt.Println(string(p))

	return config, err
}

func addConfigFileArgs(fs *flag.FlagSet) {
	fs.StringVar(new(string), configFileArgName, "", configFileArgUsage)
}
