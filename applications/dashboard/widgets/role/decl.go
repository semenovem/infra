package role

import (
	"applications/dashboard/types"
	"github.com/rivo/tview"
	"io"
	"log/slog"
	"os"
	"strings"
)

type Widget struct {
	logger       *slog.Logger
	informerView *tview.TextView
	panel        *tview.Flex
	roleFilePath string
	currentRole  string
	selectedRole string
	ctrl         types.Control
}

func NewWidgetRole(logger *slog.Logger, core types.Control) *Widget {
	box := tview.NewTextView().SetMaxLines(1)
	box.SetBorder(true).
		SetBorderPadding(0, 0, 1, 0).
		SetTitle("  role  ")

	return &Widget{
		logger:       logger.With("widget", "role"),
		informerView: box,
		roleFilePath: core.GetRepoPath() + "/.local/role",
		ctrl:         core,
	}
}

func (w *Widget) DrawInformer() tview.Primitive {
	w.informerView.SetTextColor(tview.Styles.PrimaryTextColor)

	err := w.readRole()
	if err != nil {
		w.logger.With("error", err).Error("(DrawInformer) Error reading role")
		w.informerView.SetText(err.Error())
	} else {
		w.informerView.SetText(w.currentRole)
	}

	return w.informerView
}

func (w *Widget) updateInformer() {
	w.logger.Info("(Widget.updateInformer) currentRole: " + w.currentRole)
	w.informerView.SetText(w.currentRole)
}

func (w *Widget) readRole() error {
	file, err := os.Open(w.roleFilePath)
	if err != nil {
		w.logger.With("error", err).Error("(getLastUpdate) failed os.Open")
		return err
	}

	defer func() {
		if err = file.Close(); err != nil {
			w.logger.With("error", err).Error("(getLastUpdate) failed file.Close")
		}
	}()

	b, err := io.ReadAll(file)
	if err != nil {
		w.logger.With("error", err).Error("(getLastUpdate) failed io.ReadAll")
		return err
	}

	w.currentRole = strings.TrimSpace(string(b))

	return nil
}
