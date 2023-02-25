package tasks

func newVersionTask() *Task {
	return &Task{
		name:  versionTaskName,
		usage: versionFlagUsage,
		run: func(_ *Task) error {
			loggerInfo.Println(GetAppVersion())
			return nil
		},
		offConfigFileFlag: true,
		offDebugFlag:      true,
	}
}

func newHelpTask() *Task {
	return &Task{
		name:  helpTaskName,
		usage: helpFlagUsage,
		run: func(_ *Task) error {
			Help()
			return nil
		},
		offConfigFileFlag: true,
		offDebugFlag:      true,
	}
}
