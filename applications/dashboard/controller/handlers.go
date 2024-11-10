package controller

import (
	"fmt"
	"github.com/rivo/tview"
)

func (t *Controller) Exit() {
	t.logger.Info("(Controller.Exit)")
	t.app.Stop()
}

func (t *Controller) SetFocus(el tview.Primitive) {
	t.logger.Info(fmt.Sprintf("(Controller.SetFocus) open view change role %T", el))
	t.app.SetFocus(el)
}

func (t *Controller) OpenViewChangeRole() {
	t.logger.Info("(Controller.OpenViewChangeRole) open view change role")
	t.widgetRole.DrawEditor()
}
