package cmd

func newPKITask() *Task {
	return &Task{
		name:  pkiCmdName,
		usage: "название pki хранилища",
		flags: []flagSet{addHostFlag},
		run:   getPKITask,
	}
}

func getPKITask(t *Task) error {
	hostName := getHostFlag(t.fs)

	pkiName, err := t.cfg.GetPKI(hostName)
	if err != nil {
		return err
	}

	loggerInfo.Println(pkiName)

	return nil
}
