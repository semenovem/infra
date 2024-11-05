package widget_menu

import (
	"context"
	"os/exec"
)

func (w *WidgetMenu) updateRepo(ctx context.Context) {
	cmd := exec.CommandContext(
		ctx,
		"git",
		"-C",
		w.conf.PathRepo,
		"pull",
	)

	stdout, err := cmd.Output()
	if err != nil {
		w.logger.Error("updateRepo", "error", err.Error())
	} else {
		w.logger.Info("updateRepo", "stdout", string(stdout))
	}
}
