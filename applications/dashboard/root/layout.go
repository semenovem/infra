package root

import (
	"context"
	"github.com/rivo/tview"
	"infra_menu/widgets/widget_infra_repo"
	"infra_menu/widgets/widget_log"
	"infra_menu/widgets/widget_menu"
)

func (t *Controller) buildRootLayout(ctx context.Context, outputLog <-chan []byte) {
	var (
		layout    = tview.NewFlex()
		leftSide  = tview.NewFlex().SetDirection(tview.FlexColumn)
		rightSide = tview.NewFlex().SetDirection(tview.FlexRow)
	)

	layout.
		AddItem(leftSide, 0, 1, true).
		AddItem(rightSide, 0, 2, false)

	// --------------------- Left Menu
	var (
		widgetMenu = widget_menu.New(widget_menu.Config{
			PathRepo:                t.infraRepoPath,
			HandlerExit:             t.Exit,
			HandlerShowModal:        t.ShowModal,
			HandlerHideModal:        t.HideModal,
			HandlerSetFocus:         t.SetFocus,
			HandlerChangeRole:       t.OpenViewChangeRole,
			HandlerShowConfirmModal: t.ShowConfirmModal,
		}, t.logger)
	)

	leftSide.AddItem(widgetMenu.Draw(ctx), 0, 1, false)

	// --------------------- Right Menu
	var (
		widgetInfra = widget_infra_repo.New(t.infraRepoPath, t.logger)
		//widgetRole  = widget_role.NewWidgetRole(t.infraRepoPath, t.logger)
		widgetLog = widget_log.New()
	)

	rightSide.AddItem(widgetInfra.Draw(ctx), 7, 0, false)
	rightSide.AddItem(t.widgetRole.DrawInformer(), 4, 0, false)
	rightSide.AddItem(widgetLog.Draw(), 0, 1, false)

	go func() {
		for d := range outputLog {
			widgetLog.Input(d)
			t.app.Draw()
		}
	}()

	t.pages.AddPage("background", layout, true, true)

	t.SetFocus(widgetMenu.Draw(ctx))
}
