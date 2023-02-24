package tasks

func newPortForwardingTask() *Task {
	return &Task{
		name:  "port-forwarding",
		usage: "данные о пробросе портов",
		flags: []flagSet{addHostFlag},
		run:   sshPortForwardingTask,
	}
}

func sshPortForwardingTask(t *Task) error {
	var (
		hostName       = getHostFlag(t.fs)
		portForwarding = t.cfg.GetProxyForwardingByHostName(hostName)
	)

	loggerDebug.Printf("portForwarding = %+v\n", portForwarding)

	return nil
}
