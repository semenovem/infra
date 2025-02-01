package log_zone

import (
	"fmt"
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
	"sync"
)

type WidgetLog struct {
	box  *tview.TextView
	once sync.Once
}

func New() *WidgetLog {
	box := tview.NewTextView().
		SetDynamicColors(true).
		SetRegions(true).SetTextColor(tcell.ColorGrey)

	box.SetBorder(true).SetTitle("  logs  ")

	return &WidgetLog{
		box: box,
	}
}

func (w *WidgetLog) Draw() tview.Primitive {
	w.once.Do(w.draw)
	return w.box
}

func (w *WidgetLog) draw() {
	w.box.SetBorderPadding(0, 0, 1, 0)
}

func (w *WidgetLog) Input(text []byte) {
	if _, err := w.box.Write(text); err != nil {
		fmt.Println("(ERRO.WidgetLog.handle) ", err.Error())
	}

	w.box.ScrollToEnd()
}
