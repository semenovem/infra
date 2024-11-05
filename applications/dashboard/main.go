package main

import (
	"context"
	"infra_menu/root"
	"log/slog"
	"os"
	"time"
)

var (
	infraRepoPath = os.Getenv("HOME") + "/_infra"
)

var (
	logger          *slog.Logger
	mainCtx, cancel = context.WithCancel(context.Background())
	inputLog        = make(chan []byte, 100)
	middleware      = loggerMiddleware{out: os.Stdout, inputLog: inputLog}
)

type loggerMiddleware struct {
	out      *os.File
	inputLog chan []byte
}

func (m *loggerMiddleware) Write(p []byte) (n int, err error) {
	a := make([]byte, len(p))
	copy(a, p)
	m.inputLog <- a

	return 0, nil

	//return m.out.Write(p)
}

func main() {
	logger = slog.New(slog.NewTextHandler(&middleware, &slog.HandlerOptions{
		Level: slog.LevelInfo,
		ReplaceAttr: func(groups []string, a slog.Attr) slog.Attr {
			if a.Key == slog.TimeKey {
				return slog.Attr{}
			}

			return a
		},
	}))

	defer cancel()
	defer time.Sleep(time.Millisecond * 50)
	defer logger.Info("exit application")

	logger.Info("start application")

	//logger.Info("Before Python shell:")
	//cmd := exec.Command(
	//	"bash",
	//	"-c",
	//	//"echo '>>>>>>>>>>>>>>>>'; sleep 5",
	//	"sh /Users/sem/_infra/bin/util/sys/_test_set-role.sh",
	//)
	//cmd.Stdin = os.Stdin
	//cmd.Stdout = os.Stdout
	//cmd.Stderr = os.Stderr
	//err := cmd.Run()
	//logger.Info("After Python shell", err)

	_ = root.New(mainCtx, logger, infraRepoPath, inputLog)
}
