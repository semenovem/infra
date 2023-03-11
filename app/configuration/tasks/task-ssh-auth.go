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
	roleName := getRoleFlag(t.fs)

	err := t.cfg.IsRoleExists(roleName)
	if err != nil {
		return err
	}

	var (
		allowRoles = t.cfg.GetAllowIncomingSSHByRole(roleName)
		pybKeys    = t.cfg.GetPubKeysOfUserMainByRoles(allowRoles)
	)

	for _, k := range pybKeys {
		loggerInfo.Printf(k)
	}

	return nil
}
