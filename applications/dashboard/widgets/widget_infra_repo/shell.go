package widget_infra_repo

import (
	"context"
	"fmt"
	"os/exec"
	"strings"
)

func gitBranchName(ctx context.Context, path string) (string, error) {
	cmd := exec.CommandContext(
		ctx,
		"sh",
		"-c",
		fmt.Sprintf("cd %s && git rev-parse --abbrev-ref HEAD", path),
	)
	//cmd := exec.CommandContext(ctx, "git", "-C", path, "rev-parse", "--abbrev-ref", "HEAD")

	stdout, err := cmd.Output()
	if err != nil {
		return "", err
	}

	return strings.TrimSpace(string(stdout)), nil
}

func gitShortCommit(ctx context.Context, path string) (string, error) {
	cmd := exec.CommandContext(
		ctx,
		"sh",
		"-c",
		fmt.Sprintf("cd %s && git rev-parse --short HEAD", path),
	)
	//cmd := exec.CommandContext(ctx, "git", "-C", path, "rev-parse", "--short", "HEAD")

	stdout, err := cmd.Output()
	if err != nil {
		return "", err
	}

	return strings.TrimSpace(string(stdout)), nil
}
