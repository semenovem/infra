package tasks

import (
	"errors"
	"flag"
	"fmt"
	"gopkg.in/yaml.v3"
	"io"
	"log"

	"configuration/configs"
)

var (
	loggerInfo, loggerDebug *log.Logger
)

type flagSet func(*flag.FlagSet)

type Task struct {
	fs      *flag.FlagSet
	isDebug bool
	name    string
	usage   string
	flags   []flagSet
	run     func(*Task) error
}

func New() []*Task {
	return []*Task{
		newHelpTask(),
		newVersionTask(),
		newVerifierTask(),
		newSSHConfigTask(),
		newSSHAuthorizedKeysTask(),
	}
}

func SetLoggers(logInfo, logDebug *log.Logger) {
	loggerInfo = logInfo
	loggerDebug = logDebug
}

func Help() {
	loggerInfo.Printf("Команды: ")

	for _, task := range New() {
		loggerInfo.Printf("%-20s # %s", task.name, task.usage)
	}
}

func (t *Task) Name() string {
	return t.name
}

func (t *Task) Init(args []string) error {
	t.fs = flag.NewFlagSet(t.name, flag.ContinueOnError)
	t.fs.SetOutput(io.Discard)

	switch t.name {
	case versionTaskName, helpTaskName:
	default:
		t.fs.BoolVar(&t.isDebug, debugFlagName, false, debugFlagUsage)
		t.fs.StringVar(new(string), configFileFlagName, "", configFileFlagUsage)
	}

	for _, f := range t.flags {
		f(t.fs)
	}

	err := t.fs.Parse(args)
	if err != nil {
		if errors.Is(err, flag.ErrHelp) {
			return err
		}

		return fmt.Errorf("tasks.Init(parse args): %s", err.Error())
	}

	if t.isDebug {
		loggerDebug.Println("DEBUG:")
		t.fs.VisitAll(func(f *flag.Flag) {
			loggerDebug.Printf("%s=%s", f.Name, f.Value)
		})
	}

	return nil
}

func (t *Task) Run() error {
	return t.run(t)
}

func (t *Task) Help() string {
	loggerInfo.Printf(" %-21s # %s", t.name, t.usage)
	t.fs.VisitAll(func(f *flag.Flag) {
		def := ""
		if f.DefValue != "" {
			def = "(default: " + f.DefValue + ")"
		}
		loggerInfo.Printf(" -%-20s # %s %s", f.Name, f.Usage, def)
	})

	return ""
}

func (t *Task) getConfigFile() (*configs.Config, error) {
	fileName := t.fs.Lookup(configFileFlagName).Value.String()

	config, err := configs.ParseConfigFile(fileName)
	if err != nil {
		return nil, fmt.Errorf("tasks.getConfigFile: %s", err.Error())
	}

	// TODO для отладки
	p, _ := yaml.Marshal(config)
	fmt.Println(string(p))

	return config, err
}

func newVersionTask() *Task {
	return &Task{
		name:  versionTaskName,
		usage: versionFlagUsage,
		run: func(_ *Task) error {
			loggerInfo.Println("configuration v1.0.0")
			return nil
		},
	}
}

func newHelpTask() *Task {
	return &Task{
		name:  helpTaskName,
		usage: helpFlagUsage,
		run: func(_ *Task) error {
			Help()
			return nil
		},
	}
}
