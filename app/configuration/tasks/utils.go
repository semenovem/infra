package tasks

import (
	"fmt"
	"os"
)

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

func newPWDTask() *Task {
	return &Task{
		name:  pwdTaskName,
		usage: "Текущая директория",
		run: func(_ *Task) error {
			path, err := os.Getwd()
			if err != nil {
				return fmt.Errorf("tasks.PWDTask.run: %ds", err.Error())
			}
			loggerInfo.Println(path)

			return nil
		},
		offConfigFileFlag: true,
		offDebugFlag:      true,
	}
}
