package tasks

func newSSHConfigTask() *Task {
	return &Task{
		name:  "ssh-config",
		usage: "создать файл ssh config",
		flags: []flagSet{addHostFlag},
		run:   sshConfigTask,
	}
}

func sshConfigTask(t *Task) error {
	cfg, err := t.getConfigFile()
	if err != nil {
		return err
	}

	loggerDebug.Printf("%+v", cfg)

	return nil
}
