package tasks

func newSSHAuthorizedKeysTask() *Task {
    return &Task{
        name:  "ssh-authorized-keys",
        usage: "создать файл ssh authorized_keys",
        flags: []flagSet{addHostFlag},
        run:   sshAuthorizedKeysTask,
    }
}

func sshAuthorizedKeysTask(t *Task) error {
    cfg, err := t.getConfigFile()
    if err != nil {
        return err
    }

    loggerDebug.Printf("%+v", cfg)

    return nil
}
