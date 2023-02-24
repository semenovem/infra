package tasks

import "flag"

const (
	configFileFlagUsage = "файл конфигурации"
	debugFlagUsage      = "отладочный вывод"
	hostFlagUsage       = "название хоста"
	helpFlagUsage       = "список команд"
	versionFlagUsage    = "версия приложения"

	// флаги
	debugFlagName      = "debug"
	hostFlagName       = "host"
	configFileFlagName = "config-file"

	// команды
	versionTaskName = "version"
	helpTaskName    = "help"
)

func addConfigFileFlag(fs *flag.FlagSet) {
	fs.StringVar(new(string), configFileFlagName, "", configFileFlagUsage)
}

func addHostFlag(fs *flag.FlagSet) {
	fs.StringVar(new(string), hostFlagName, "", hostFlagUsage)
}
