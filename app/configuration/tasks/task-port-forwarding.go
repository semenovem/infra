package tasks

import (
	"fmt"
	"strings"
)

func newPortForwardingTask() *Task {
	return &Task{
		name:  sshRemoteForwardTaskName,
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

	fmt.Println(">>>>>>>>>> ", localForward)

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
