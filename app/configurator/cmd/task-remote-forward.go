package cmd

func newPortForwardingTask() *Task {
	return &Task{
		name:  sshRemoteForwardCmdName,
		usage: "данные о пробросе портов",
		flags: []flagSet{addHostFlag},
		run:   sshRemoteForwardTask,
	}
}

func sshRemoteForwardTask(t *Task) error {
	hostName := getHostFlag(t.fs)

	conns, err := t.cfg.GetSSHConnForward(hostName)
	if err != nil {
		return err
	}

	for _, v := range conns {
		loggerInfo.Println(v.FormatRemote())
	}

	return nil
}
