package tasks

import (
	"flag"
	"strings"
)

const (
	configFileFlagUsage = "файл конфигурации"
	debugFlagUsage      = "отладочный вывод"
	hostFlagUsage       = "имя хоста"
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

func addHostFlag(fs *flag.FlagSet) {
	fs.StringVar(new(string), hostFlagName, "", hostFlagUsage)
}

func getHostFlag(fs *flag.FlagSet) (host string) {
	return strings.ToLower(fs.Lookup(hostFlagName).Value.String())
}
