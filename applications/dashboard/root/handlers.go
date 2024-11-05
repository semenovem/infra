package root

import (
	"github.com/rivo/tview"
)

func (t *Controller) Exit() {
	t.logger.Info("(Controller.Exit)")
	t.app.Stop()
}

func (t *Controller) SetFocus(el tview.Primitive) {
	t.app.SetFocus(el)
}

func (t *Controller) OpenViewChangeRole() {
	t.logger.Info("(Controller.OpenViewChangeRole) open view change role")
	t.widgetRole.DrawEditor()
}

func (t *Controller) hideApp() {
	t.logger.Info("(OpenViewChangeRole) open view change role")
	t.widgetRole.DrawEditor()
}
