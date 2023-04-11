package tasks

import (
	"flag"
	"strings"
)

const (
	// Описание флагов
	configFileFlagUsage = "файл конфигурации"
	debugFlagUsage      = "отладочный вывод"
	hostFlagUsage       = "имя хоста"
	helpFlagUsage       = "список команд"
	versionFlagUsage    = "версия приложения"
	roleFlagUsage       = "роль"

	// Флаги
	debugFlagName      = "debug"
	hostFlagName       = "host"
	configFileFlagName = "config-file"
	roleFlagName       = "role"

	// Команды
	versionTaskName           = "version"
	helpTaskName              = "help"
	pwdTaskName               = "pwd"
	sshRemoteForwardTaskName  = "ssh-remote-forward"
	sshAuthorizedKeysTaskName = "ssh-authorized-keys"
	sshConfigTaskName         = "ssh-config"
	verifyTaskName            = "verify"
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
