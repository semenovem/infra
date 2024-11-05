package root

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"time"
)

func (t *Controller) interactiveShell(ctx context.Context) {
	t.logger.Info("(Controller.interactiveShell) run")

	t.executeShellFile(ctx, "")
}

func (t *Controller) ExecuteShellFile(ctx context.Context, filePath string, args ...string) {
	t.logger.Info("(Controller.ExecuteShellFile) run", "filePath", filePath)

	t.executeShellFile(ctx, filePath, args...)

	time.Sleep(2 * time.Second)
}

func (t *Controller) executeShellFile(ctx context.Context, filePath string, args ...string) {
	t.isRestart = true

	t.app.Stop()

	shell := os.Getenv("SHELL")
	if shell == "" {
		shell = "bash"
	}

	ps1 := "\\033[0;31m[SUBSHELL-DASHBOARD-GUI][ctrl+d]\\033[0m \\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ "

	switch runtime.GOOS {
	case "darwin":
		shell = "sh"
	default:
	}

	cmd := exec.CommandContext(
		ctx,
		shell,
		"-c",
		fmt.Sprintf(
			"export PS1='%s'; export PROMPT='>>>'; %s %s %s",
			ps1,
			shell,
			filePath,
			strings.Join(args, " "),
		),
	)

	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	//_, _ = cmd.Stdout.Write([]byte("[INFO] > start subshell\n"))
	//_, _ = cmd.Stdout.Write([]byte("[INFO] > press ctrl+d to exit\n"))

	if err := cmd.Run(); err != nil {
		t.logger.Error("(Controller.interactiveShell) return", "error", err)
		stdout, err := cmd.Output()
		if err == nil {
			t.logger.Error("(Controller.interactiveShell)", "output", string(stdout))
		}
	} else {
		t.logger.Info("(Controller.interactiveShell) return")
		stdout, _ := cmd.Output()
		t.logger.Info("(Controller.interactiveShell)", "output", string(stdout))
	}
}
