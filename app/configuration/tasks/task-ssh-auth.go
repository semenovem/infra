package tasks

func newSSHAuthorizedKeysTask() *Task {
	return &Task{
		name:  "ssh-authorized-keys",
		usage: "список публичных ssh ключей для authorization_keys",
		flags: []flagSet{addRoleFlag},
		run:   sshAuthorizedKeysTask,
	}
}

func sshAuthorizedKeysTask(t *Task) error {
	var (
		role       = getRoleFlag(t.fs)
		allowRoles = t.cfg.GetAllowIncomingSSHByRole(role)
		pybKeys    = t.cfg.GetPubKeysOfUserMainByRoles(allowRoles)
	)

	for _, k := range pybKeys {
		loggerInfo.Printf(k)
	}

	return nil
}
