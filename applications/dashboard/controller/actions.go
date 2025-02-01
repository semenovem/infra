package controller

import (
	"applications/entities/roles"
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

func (t *Controller) SetRoleMachine(r roles.Role) error {
	t.logger.Info(fmt.Sprintf("(SetRoleMachine) new role: %s ", r))

	//content := strings.ToUpper(strings.TrimSpace(w.selectedRole))

	//err := os.WriteFile(t.infraRepoPath, []byte(content), 0600)
	//if err != nil {
	//	t.logger.With("error", err).Error("failed to save role")
	//} else {
	//	t.currentRole = w.selectedRole
	//	t.updateInformer()
	//}
	return nil
}

func (t *Controller) GetRoleMachine() (roles.Role, error) {
	t.logger.Info("(Controller.OpenViewChangeRole) open view change role")
	return "", nil
}
