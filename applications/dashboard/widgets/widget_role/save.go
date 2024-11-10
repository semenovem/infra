package widget_role

import (
	"fmt"
	"os"
	"strings"
)

func (w *WidgetRole) saveRole() {
	w.logger.Info(fmt.Sprintf("(saveRole) old: %s new: %s ", w.selectedRole))

	content := strings.ToUpper(strings.TrimSpace(w.selectedRole))

	err := os.WriteFile(w.roleFilePath, []byte(content), 0600)
	if err != nil {
		w.logger.With("error", err).Error("failed to save role")
	} else {
		w.currentRole = w.selectedRole
		w.updateInformer()
	}

	// TODO показать модальное окно с ошибкой

	w.conf.HandlerHideModal()
}
