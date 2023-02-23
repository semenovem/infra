package main

type verifyTask struct {
	base
}

func (t *verifyTask) Run() error {
	cfg, err := t.base.getConfigFile()
	if err != nil {
		return err
	}

	loggerDebug.Printf("%+v", cfg)

	return nil
}
