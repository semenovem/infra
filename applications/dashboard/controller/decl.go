package controller

import (
	"applications/dashboard/widgets/role"
	"context"
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
	"log/slog"
)

type Controller struct {
	logger           *slog.Logger
	app              *tview.Application
	pages            *tview.Pages
	infraRepoPath    string
	isModalOpened    bool
	focusedElemStack []tview.Primitive
	widgetRole       *role.Widget
	isRestart        bool
}

func New(
	ctx context.Context,
	logger *slog.Logger,
	infraRepoPath string,
	inputLog <-chan []byte,
) error {
	v := &Controller{
		logger:        logger.With("module", "controller"),
		app:           tview.NewApplication(),
		pages:         tview.NewPages(),
		infraRepoPath: infraRepoPath,
	}

	v.app.SetRoot(v.pages, true)

	widgetRole := role.NewWidgetRole(v.logger, v)

	v.widgetRole = widgetRole

	//v.buildRootLayout(ctx, inputLog)
	v.buildGrid(ctx, inputLog)

	v.app.SetInputCapture(func(event *tcell.EventKey) *tcell.EventKey {
		if v.isModalOpened {
			return event
		}

		switch event.Rune() {
		case 'q', 'й':
			v.logger.Info("pressed 'q' key - exiting")
			v.Exit()
			return nil
		}

		switch event.Key() {
		case tcell.KeySI: // перейти в shell
			v.interactiveShell(ctx)
			return nil
		default:
		}

		//logger.With(
		//	"key", event.Key(),
		//	"name", event.Name(),
		//	"rune", event.Rune(),
		//).Debug("root")

		return event
	})

	for {
		v.isRestart = false

		if err := v.app.Run(); err != nil {
			v.logger.Error("run: %w", err)
			return err
		}

		if !v.isRestart {
			return nil
		}
	}
}
