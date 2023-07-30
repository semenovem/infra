package cmd

func newSSHConnTask() *Task {
	return &Task{
		name:  sshConnCmdName,
		usage: "ssh подключение",
		flags: []flagSet{addHostFlag},
		run:   sshConnTask,
	}
}

func sshConnTask(t *Task) error {
	hostName := getHostFlag(t.fs)

	sshConn, err := t.cfg.GetSSHConn(hostName)
	if err != nil {
		return err
	}

	loggerInfo.Println(sshConn)

	return nil
}
