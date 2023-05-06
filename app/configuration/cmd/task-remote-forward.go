package tasks

import (
	"fmt"
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
		hostName = getHostFlag(t.fs)
	)

	conns, err := t.cfg.GetSSHConnForward(hostName)
	if err != nil {
		return err
	}

	for _, v := range conns {
		fmt.Printf(">>>>>>  %+v\n ", v.Format())
	}

	//fmt.Println()
	//var (
	//	//hostName     = getHostFlag(t.fs)
	//	localForward = t.cfg.GetSSHLocalForwardByHostName(hostName)
	//)

	//fmt.Println(">>>>>>>>>> hostname", hostName)
	//fmt.Println(">>>>>>>>>> ", localForward)

	//if localForward != nil {
	//	hosts, err := localForward.GetItems()
	//	if err != nil {
	//		return err
	//	}
	//
	//	for host, ports := range hosts {
	//		loggerInfo.Printf("%s %s", host, strings.Join(ports, " "))
	//	}
	//}

	return nil
}
