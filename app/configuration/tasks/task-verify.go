package tasks

func newVerifierTask() *task {
	return &task{
		name:  "verifier",
		flags: []flagSet{},
		run:   verifierTask,
	}
}

func verifierTask(t *task) error {
	cfg, err := t.getConfigFile()
	if err != nil {
		return err
	}

	loggerDebug.Printf("%+v", cfg)

	return nil
}
