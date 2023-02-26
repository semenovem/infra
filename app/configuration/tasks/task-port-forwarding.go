package tasks

import "strings"

func newPortForwardingTask() *Task {
	return &Task{
		name:  "ssh-remote-forward",
		usage: "данные о пробросе портов",
		flags: []flagSet{addHostFlag},
		run:   sshRemoteForwardTask,
	}
}

func sshRemoteForwardTask(t *Task) error {
	var (
		hostName     = getHostFlag(t.fs)
		localForward = t.cfg.GetSSHLocalForwardByHostName(hostName)
	)

	if localForward != nil {
		hosts, err := localForward.GetItems()
		if err != nil {
			return err
		}

		for host, ports := range hosts {
			loggerInfo.Printf("%s %s", host, strings.Join(ports, " "))
		}
	}

	return nil
}
