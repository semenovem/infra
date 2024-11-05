package root

import (
	"context"
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
	"infra_menu/widgets/widget_role"
	"log/slog"
)

type Controller struct {
	logger           *slog.Logger
	app              *tview.Application
	pages            *tview.Pages
	infraRepoPath    string
	isModalOpened    bool
	focusedElemStack []tview.Primitive
	widgetRole       *widget_role.WidgetRole
}

func New(
	ctx context.Context,
	logger *slog.Logger,
	infraRepoPath string,
	inputLog <-chan []byte,
) *Controller {
	v := &Controller{
		logger:        logger,
		app:           tview.NewApplication(),
		pages:         tview.NewPages(),
		infraRepoPath: infraRepoPath,
	}

	v.app.SetRoot(v.pages, true)

	widgetRole := widget_role.NewWidgetRole(widget_role.Config{
		PathRepo:         v.infraRepoPath,
		HandlerShowModal: v.ShowModal,
		HandlerHideModal: v.HideModal,
		HandlerSetFocus:  v.SetFocus,
	}, v.logger)

	v.widgetRole = widgetRole

	v.buildRootLayout(ctx, inputLog)

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
		case tcell.KeySI:
			logger.Info(">>>>>>>>>>>")
			return nil
		default:
		}

		logger.With(
			"key", event.Key(),
			"name", event.Name(),
			"rune", event.Rune(),
		).Info("root")

		return event
	})

	if err := v.app.Run(); err != nil {
		v.logger.Error("run: %w", err)
	}

	return v
}
