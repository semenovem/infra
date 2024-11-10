package widget_role

import (
	"github.com/rivo/tview"
	"io"
	"log/slog"
	"os"
	"strings"
)

type WidgetRole struct {
	logger       *slog.Logger
	informerView *tview.TextView
	panel        *tview.Flex
	roleFilePath string
	conf         Config
	currentRole  string
	selectedRole string
}

type Config struct {
	PathRepo         string
	HandlerShowModal func(el tview.Primitive, width, height int)
	HandlerHideModal func()
	HandlerSetFocus  func(tview.Primitive)
}

func NewWidgetRole(conf Config, logger *slog.Logger) *WidgetRole {
	box := tview.NewTextView().SetMaxLines(1)
	box.SetBorder(true).
		SetBorderPadding(0, 0, 1, 0).
		SetTitle("  role  ")

	return &WidgetRole{
		logger:       logger.With("comp", "WidgetRole"),
		informerView: box,
		roleFilePath: conf.PathRepo + "/.local/role",
		conf:         conf,
	}
}

func (w *WidgetRole) DrawInformer() tview.Primitive {
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

func (w *WidgetRole) updateInformer() {
	w.logger.Info("(WidgetRole.updateInformer) currentRole: " + w.currentRole)
	w.informerView.SetText(w.currentRole)
}

func (w *WidgetRole) readRole() error {
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
