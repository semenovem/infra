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
	cfg, err := t.getConfigFile()
	if err != nil {
		return err
	}

	loggerDebug.Printf("%+v", cfg)

	return nil
}
