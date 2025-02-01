package types

import (
	"applications/entities/roles"
	"context"
	"github.com/rivo/tview"
)

type Control interface {
	ShowModal(el tview.Primitive, width, height int)
	HideModal()

	ShowConfirmModal(confirmMessage string, action func())

	SetFocus(tview.Primitive)

	GetRepoPath() string

	GetRoleMachine() (roles.Role, error)
	SetRoleMachine(roles.Role) error

	ExecuteShellFile(ctx context.Context, filePath string, args ...string)
}
