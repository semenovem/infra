package tasks

func newSSHConfig() *task {
	return &task{
		name:  "ssh-config",
		flags: []flagSet{addHostFlag},
		run:   sshConfigTask,
	}
}

func sshConfigTask(t *task) error {
	cfg, err := t.getConfigFile()
	if err != nil {
		return err
	}

	loggerDebug.Printf("%+v", cfg)

	return nil
}
