package tasks

import (
	"configuration/configs"
	"flag"
	"fmt"
	"gopkg.in/yaml.v3"
	"io"
	"log"
	"os"
	"strconv"
)

var (
	loggerErr, loggerInfo, loggerDebug *log.Logger
)

type ITask interface {
	Init([]string) error
	Run() error
	Name() string
	Help() string
}

type flagSet func(*flag.FlagSet)

func New() []ITask {
	return []ITask{
		newVerifierTask(),
		newSSHConfig(),
	}
}

func SetLoggers(logErr, logInfo, logDebug *log.Logger) {
	loggerErr = logErr
	loggerInfo = logInfo
	loggerDebug = logDebug
}

type task struct {
	fs      *flag.FlagSet
	isDebug bool
	name    string
	flags   []flagSet
	run     func(*task) error
}

func (t *task) Name() string {
	return t.name
}

func (t *task) Init(args []string) error {
	t.fs = flag.NewFlagSet(t.name, flag.ContinueOnError)
	t.fs.SetOutput(io.Discard)

	addDebugFlag(t.fs)
	addConfigFileFlag(t.fs)

	for _, f := range t.flags {
		f(t.fs)
	}

	err := t.fs.Parse(args)
	if err != nil {
		//if errors.Is(err, flag.ErrHelp) {
		//    return err
		//}

		loggerErr.Println("parse: ", err)

		t.fs.VisitAll(func(f *flag.Flag) {
			loggerDebug.Printf("%s=%s", f.Name, f.Value)
		})

		return err
	}

	t.isDebug, err = strconv.ParseBool(t.fs.Lookup(debugFlagName).Value.String())
	if err != nil {
		loggerErr.Println(err)
		return err
	}

	if t.isDebug {
		loggerInfo.Println("DEBUG:")
		t.fs.VisitAll(func(f *flag.Flag) {
			loggerDebug.Printf("%s=%s", f.Name, f.Value)
		})
	}

	return nil
}

func (t *task) Run() error {
	return t.run(t)
}

func (t *task) Help() string {
	t.fs.VisitAll(func(f *flag.Flag) {
		_, _ = fmt.Fprintln(os.Stdout, f.Usage)
		//fmt.Println(f.Usage)
	})
	return ""
}

func (t *task) getConfigFile() (*configs.Config, error) {
	fileName := t.fs.Lookup(configFileFlagName).Value.String()

	config, err := configs.ParseConfigFile(fileName)
	if err != nil {
		loggerErr.Println(err)
		return nil, err
	}

	// TODO для отладки
	p, _ := yaml.Marshal(config)
	fmt.Println(string(p))

	return config, err
}
