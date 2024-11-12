package controller

import (
	"applications/entities/roles"
	"fmt"
	"github.com/rivo/tview"
	"os"
	"strings"
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

func (t *Controller) SetRoleMachine(r roles.Role) error {
	w.logger.Info(fmt.Sprintf("(saveRole) old: %s new: %s ", w.selectedRole))

	content := strings.ToUpper(strings.TrimSpace(w.selectedRole))

	err := os.WriteFile(w.roleFilePath, []byte(content), 0600)
	if err != nil {
		w.logger.With("error", err).Error("failed to save role")
	} else {
		w.currentRole = w.selectedRole
		w.updateInformer()
	}
}
