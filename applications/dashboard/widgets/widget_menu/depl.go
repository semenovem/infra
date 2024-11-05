package widget_menu

import (
	"context"
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
	"log/slog"
	"sync"
)

type WidgetMenu struct {
	box    *tview.List
	once   sync.Once
	conf   Config
	logger *slog.Logger
}

type Config struct {
	PathRepo                string
	HandlerExit             func()
	HandlerShowModal        func(el tview.Primitive, width, height int)
	HandlerHideModal        func()
	HandlerSetFocus         func(tview.Primitive)
	HandlerChangeRole       func()
	HandlerShowConfirmModal func(confirmMessage string, action func())
}

func New(conf Config, logger *slog.Logger) *WidgetMenu {
	box := tview.NewList().ShowSecondaryText(false)
	box.SetBorder(true).
		SetBorderPadding(0, 0, 1, 0).
		SetTitle("  role  ")

	return &WidgetMenu{
		box:    box,
		conf:   conf,
		logger: logger.With("module", "widget_menu"),
	}
}

func (w *WidgetMenu) Draw(ctx context.Context) tview.Primitive {
	w.once.Do(func() {
		w.draw(ctx)
	})

	return w.box
}

func (w *WidgetMenu) draw(ctx context.Context) {
	w.box.
		AddItem("Reinstall", "", '1', nil).
		AddItem("Update repo", "", '2', func() {
			w.conf.HandlerShowConfirmModal(
				"Confirm Update Repo ?",
				func() {
					w.updateRepo(ctx)
					w.conf.HandlerHideModal()
				},
			)
		}).
		AddItem("Update ssh config", "", '3', func() {

			//w.logger.Info("Before Python shell:")
			//cmd := exec.Command(
			//	"bash",
			//	"-c",
			//	"echo '>>>>>>>>>>>>>>>>'; sleep 3",
			//	//"/Users/sem/_infra/bin/util/sys/_test_set-role.sh",
			//)
			//cmd.Stdin = os.Stdin
			//cmd.Stdout = os.Stdout
			//cmd.Stderr = os.Stderr
			//err := cmd.Run() // add error checking
			//w.logger.Info("After Python shell", err)

		}).
		AddItem("Update ssh authorized keys", "", '4', nil).
		AddItem("Build configurator app", "", '5', nil).
		AddItem("Change role", "Press to exit", '6', func() {
			w.conf.HandlerChangeRole()
		}).
		AddItem("Exit", "Press to exit", 'q', func() {
			w.conf.HandlerExit()
		})

	w.box.SetTitle(" Operations ").
		SetBorder(true).
		SetBorderStyle(tcell.Style{}.Bold(true).Dim(true).Normal().StrikeThrough(true)).
		SetBorderPadding(0, 1, 1, 1)
}
