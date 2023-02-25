package tasks

import (
	"configuration/configs"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

var (
	loggerInfo, loggerDebug *log.Logger
	GetAppVersion           func() string
)

type flagSet func(*flag.FlagSet)

type Task struct {
	fs                *flag.FlagSet
	isDebug           bool
	name              string
	usage             string
	flags             []flagSet
	run               func(*Task) error
	allowEmptyFlags   []string // Допустимы пустые значения
	cfg               *configs.Config
	configFileFlagVal string
	offConfigFileFlag bool // Не использовать флаг файла конфига
	offDebugFlag      bool // Не использовать флаг отладки
}

func New() []*Task {
	return []*Task{
		newHelpTask(),
		newVersionTask(),
		newVerifierTask(),
		newSSHConfigTask(),
		newSSHAuthorizedKeysTask(),
		newPortForwardingTask(),
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

func ShortHelp() {
	loggerInfo.Printf("use [help]  # для подробной информации")
}

func (t *Task) Name() string {
	return t.name
}

func (t *Task) Init(args []string) error {
	t.fs = flag.NewFlagSet(t.name, flag.ContinueOnError)
	t.fs.SetOutput(io.Discard)

	if !t.offConfigFileFlag {
		t.fs.StringVar(&t.configFileFlagVal, configFileFlagName, "", configFileFlagUsage)
	}

	if !t.offDebugFlag {
		t.fs.BoolVar(&t.isDebug, debugFlagName, false, debugFlagUsage)
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
		loggerDebug.SetOutput(os.Stdout)

		loggerDebug.Println("list of flags:")
		t.fs.VisitAll(func(f *flag.Flag) {
			loggerDebug.Printf("%-15s= %s", f.Name, f.Value)
		})
	}

	// Проверка заполненности значений
	emptyFlags := make([]string, 0)
	t.fs.VisitAll(func(f *flag.Flag) {
		if f.Value.String() == "" {
			emptyFlags = append(emptyFlags, "-"+f.Name)
		}
	})

	if len(emptyFlags) != 0 {
		return fmt.Errorf("flag [%s] is empty", strings.Join(emptyFlags, ", "))
	}

	return nil
}

func (t *Task) Run() error {
	if !t.offConfigFileFlag {
		var err error
		t.cfg, err = configs.ParseConfigFile(t.configFileFlagVal)
		if err != nil {
			return fmt.Errorf("tasks.getConfigFile: %s", err.Error())
		}

		// TODO для отладки
		//p, _ := yaml.Marshal(t.cfg)
		//fmt.Println(string(p))
	}

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
