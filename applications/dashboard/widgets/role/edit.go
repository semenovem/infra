package role

import (
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
)

const (
	//fonColor := tcell.NewRGBColor(199, 199, 199)
	//fonColor := tcell.ColorDarkRed
	fonColor = tcell.ColorGrey
)

func (w *Widget) DrawEditor() {
	var (
		itemStyle = tcell.StyleDefault.Background(fonColor)

		list = tview.NewList().
			ShowSecondaryText(false).
			SetMainTextStyle(itemStyle).
			SetShortcutStyle(itemStyle)

		form = tview.NewForm().
			AddButton("Save", w.saveRole).
			AddButton("Cancel", w.conf.HandlerHideModal)
	)

	form.SetBorderPadding(0, 0, 2, 0).
		SetBackgroundColor(fonColor).
		SetInputCapture(func(event *tcell.EventKey) *tcell.EventKey {
			switch event.Key() {
			case tcell.KeyRight, tcell.KeyLeft:
				_, btnInd := form.GetFocusedItemIndex()
				btnInd = (btnInd + 1) % 2
				form.SetFocus(btnInd)
			case tcell.KeyEscape:
				w.conf.HandlerSetFocus(list)
			default:
			}

			return event
		})

	list.
		AddItem("PROXY_SERVER", "", '1', nil).
		AddItem("HOME_SERVER", "", '2', nil).
		AddItem("WORKSTATION", "", '3', nil).
		AddItem("STANDBY_SERVER", "", '4', nil).
		AddItem("MINI_SERVER", "", '5', nil).
		AddItem("OFFICE_SERVER", "", '6', nil).
		SetSelectedFunc(func(_ int, s string, _ string, _ rune) {
			w.selectedRole = s
		}).
		SetInputCapture(func(event *tcell.EventKey) *tcell.EventKey {
			switch event.Key() {
			case tcell.KeyEscape:
				w.logger.Info("widget-role-edit: pressed escape")
				w.conf.HandlerHideModal()
			case tcell.KeyEnter:
				w.conf.HandlerSetFocus(form)
			}

			if event.Rune() == ' ' {
				w.conf.HandlerSetFocus(form)
			}

			return event
		}).
		SetBackgroundColor(fonColor).
		SetBorderPadding(1, 1, 2, 2)

	//list.SetMainTextStyle(tcell.StyleDefault.Foreground(tcell.ColorRed))

	{
		ls := list.FindItems(w.currentRole, "", false, true)
		if len(ls) != 0 {
			list.SetCurrentItem(ls[0])
		}
	}

	content := tview.NewFlex().SetDirection(tview.FlexRow)
	content.
		AddItem(list, 0, 1, false).
		AddItem(form, 2, 0, false).
		SetBackgroundColor(fonColor)

	panel := tview.NewFlex().SetDirection(tview.FlexColumn)
	panel.SetBackgroundColor(fonColor).SetBorder(true)
	panel.SetTitle(" change role ")
	panel.AddItem(content, 0, 1, true)

	w.conf.HandlerShowModal(panel, 60, 12)
	w.conf.HandlerSetFocus(list)
}
