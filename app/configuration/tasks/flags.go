package tasks

import "flag"

const (
	configFileFlagUsage = "# файл конфигурации"
	debugFlagUsage      = "# отладочный вывод"
	hostFlagUsage       = "# название хоста"

	debugFlagName      = "debug"
	configFileFlagName = "config-file"
	hostFlagName       = "host"
)

func addDebugFlag(fs *flag.FlagSet) {
	fs.BoolVar(new(bool), debugFlagName, false, debugFlagUsage)
}

func addConfigFileFlag(fs *flag.FlagSet) {
	fs.StringVar(new(string), configFileFlagName, "", configFileFlagUsage)
}

func addHostFlag(fs *flag.FlagSet) {
	fs.StringVar(new(string), hostFlagName, "", hostFlagUsage)
}
