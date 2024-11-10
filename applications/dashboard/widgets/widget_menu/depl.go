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
	HandlerExecuteShellFile func(ctx context.Context, shellFilePath string, args ...string)
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
				"Confirm\nUpdate Repo ?",
				func() {
					w.updateRepo(ctx)
					w.conf.HandlerHideModal()
				},
			)
		}).
		AddItem("Update ssh config", "", '3', func() {
			const path = "/bin/util/sys/ssh-config-upd.sh"
			w.conf.HandlerShowConfirmModal(
				"Confirm\nUpdate ssh config ?",
				func() {
					w.conf.HandlerExecuteShellFile(ctx, w.conf.PathRepo+path)
					w.conf.HandlerHideModal()
				},
			)
		}).
		AddItem("Update ssh authorized keys", "", '4', func() {
			const path = "/bin/util/sys/ssh-authorized-keys.sh"
			w.conf.HandlerShowConfirmModal(
				"Confirm\nUpdate ssh authorized keys ?",
				func() {
					w.conf.HandlerExecuteShellFile(ctx, w.conf.PathRepo+path)
					w.conf.HandlerHideModal()
				},
			)
		}).
		AddItem("Build configurator app", "", '5', func() {
			const (
				path      = "/app/configurator/build.sh"
				targetApp = "/.local/configurator-app"
			)

			w.conf.HandlerShowConfirmModal(
				"Confirm\nBuild configurator app ?",
				func() {
					w.conf.HandlerExecuteShellFile(
						ctx,
						w.conf.PathRepo+path,
						w.conf.PathRepo+targetApp,
					)
					w.conf.HandlerHideModal()
				},
			)
		}).
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
