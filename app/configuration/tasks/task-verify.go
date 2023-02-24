package tasks

func newVerifierTask() *Task {
	return &Task{
		name:  "verify",
		usage: "проверяет валидность файла конфигурации",
		flags: []flagSet{},
		run:   verifierTask,
	}
}

func verifierTask(t *Task) error {
	loggerDebug.Printf("verifierTask")

	return nil
}
