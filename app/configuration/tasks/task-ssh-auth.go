package tasks

func newSSHAuthorizedKeysTask() *Task {
	return &Task{
		name:  "ssh-authorized-keys",
		usage: "создать файл ssh authorized_keys",
		flags: []flagSet{addHostFlag},
		run:   sshAuthorizedKeysTask,
	}
}

func sshAuthorizedKeysTask(t *Task) error {
	cfg := t.cfg

	var (
		hostName   = getHostFlag(t.fs)
		hostRole   = cfg.GetHostRoleByName(hostName)
		allowRoles = cfg.GetAllowIncomingSSHByRole(hostRole)
		pybKeys    = cfg.GetPubKeysOfUserMainByRoles(allowRoles)
	)

	loggerDebug.Printf("hostRole = %+v\n", hostRole)
	loggerDebug.Printf("pubkey = %+v\n", pybKeys)
	loggerDebug.Printf("allowRoles = %+v\n", allowRoles)

	return nil
}
