package tasks

import (
	"configuration/conf"
	"errors"
)

func newVerifierTask() *Task {
	return &Task{
		name:  verifyTaskName,
		usage: "проверяет валидность файла конфигурации",
		flags: []flagSet{},
		run:   verifierTask,
	}
}

func verifierTask(t *Task) error {
	errs := conf.Verify(t.cfg)

	for _, msg := range errs {
		loggerInfo.Println(msg)
	}

	if len(errs) != 0 {
		return errors.New("файл конфигурации содержит ошибки")
	}

	return nil
}
