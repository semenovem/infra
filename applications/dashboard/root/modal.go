package root

import (
	"fmt"
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
)

func (t *Controller) ShowModal(el tview.Primitive, width, height int) {
	t.isModalOpened = true

	focusedElem := t.app.GetFocus()
	t.focusedElemStack = append(t.focusedElemStack, focusedElem)

	t.logger.Info(fmt.Sprintf("(ShowModal) focused elem(%T)", focusedElem))

	modal := tview.NewFlex().
		AddItem(nil, 0, 1, false).
		AddItem(tview.NewFlex().SetDirection(tview.FlexRow).
			AddItem(nil, 0, 1, false).
			AddItem(el, height, 1, true).
			AddItem(nil, 0, 1, false), width, 1, true).
		AddItem(nil, 0, 1, false)

	t.pages.AddPage("modal", modal, true, true)
}

func (t *Controller) HideModal() {
	t.pages.RemovePage("modal")

	if len(t.focusedElemStack) > 0 {
		pop := t.focusedElemStack[len(t.focusedElemStack)-1]
		t.focusedElemStack = t.focusedElemStack[:len(t.focusedElemStack)-1]
		t.app.SetFocus(pop)

		t.logger.Info(fmt.Sprintf("(HideModal) set focus elem after hide modal: elem(%T)", pop))
	}

	t.isModalOpened = false
}

func (t *Controller) ShowConfirmModal(confirmMessage string, action func()) {
	t.isModalOpened = true

	focusedElem := t.app.GetFocus()
	t.focusedElemStack = append(t.focusedElemStack, focusedElem)

	t.logger.Info(fmt.Sprintf("(ShowModal) focused elem(%T)", focusedElem))

	el := tview.NewModal().
		SetText(confirmMessage).
		AddButtons([]string{" Yes ", "Cancel"}).
		SetDoneFunc(func(buttonIndex int, buttonLabel string) {
			switch buttonLabel {
			case " Yes ":
				action()
			case "Cancel":
				t.HideModal()
			}
		}).
		SetButtonActivatedStyle(tcell.Style{}.Background(tcell.ColorRed))

	el.SetInputCapture(func(event *tcell.EventKey) *tcell.EventKey {
		switch event.Key() {
		case tcell.KeyEscape:
			t.HideModal()
		}
		if event.Rune() == 'q' || event.Rune() == 'й' {
			t.HideModal()
		}
		return event
	}).SetFocusFunc(func() {
		t.logger.Info("(ShowConfirmModal) focused modal")
	})

	t.pages.AddPage("modal", el, true, true)
}
