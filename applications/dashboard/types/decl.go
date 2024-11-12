package types

import (
	"applications/entities/roles"
	"github.com/rivo/tview"
)

type Core interface {
	ShowModal(el tview.Primitive, width, height int)
	HideModal()

	ShowConfirmModal(confirmMessage string, action func())

	SetFocus(tview.Primitive)

	GetPathToRepo() string

	GetCurrentRole() (roles.Role, error)
	SetCurrentRole(roles.Role) error
}
