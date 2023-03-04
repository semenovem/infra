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
	roleFlagUsage       = "роль"

	// флаги
	debugFlagName      = "debug"
	hostFlagName       = "host"
	configFileFlagName = "config-file"
	roleFlagName       = "role"

	// команды
	versionTaskName = "version"
	helpTaskName    = "help"
)

func extract(fs *flag.FlagSet, n string) string {
	fl := fs.Lookup(n)
	if fl == nil {
		return ""
	}

	return strings.ToLower(fl.Value.String())
}

func addHostFlag(fs *flag.FlagSet) {
	fs.StringVar(new(string), hostFlagName, "", hostFlagUsage)
}

func getHostFlag(fs *flag.FlagSet) (host string) {
	return extract(fs, hostFlagName)
}

func addRoleFlag(fs *flag.FlagSet) {
	fs.StringVar(new(string), roleFlagName, "", roleFlagUsage)
}

func getRoleFlag(fs *flag.FlagSet) (host string) {
	return extract(fs, roleFlagName)
}
