package tasks

func newSSHConfigTask() *Task {
	return &Task{
		name:  sshConfigTaskName,
		usage: "создать файл ssh config",
		flags: []flagSet{addHostFlag},
		run:   sshConfigTask,
	}
}

func sshConfigTask(t *Task) error {
	loggerDebug.Printf("sshConfigTask")

	return nil
}
