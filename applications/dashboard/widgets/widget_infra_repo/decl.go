package widget_infra_repo

import (
	"context"
	"dashboard/timeago"
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
	"io"
	"log/slog"
	"os"
	"strings"
	"sync"
	"time"
)

type WidgetInfraRepo struct {
	table              *tview.Table
	path               string
	lastUpdateFilePath string
	logger             *slog.Logger
	once               sync.Once
}

func New(path string, logger *slog.Logger) *WidgetInfraRepo {
	table := tview.NewTable()
	table.SetBorder(true).SetTitle("  infra repo  ")

	return &WidgetInfraRepo{
		logger:             logger,
		table:              table,
		path:               path,
		lastUpdateFilePath: path + "/.local/last-update-repo",
	}
}

func (w *WidgetInfraRepo) Draw(ctx context.Context) tview.Primitive {
	w.once.Do(func() {
		w.draw(ctx)
	})

	return w.table
}

func (w *WidgetInfraRepo) draw(ctx context.Context) {
	w.table.SetBorderPadding(0, 0, 1, 0)

	w.drawCell(0, 0, "path", false)
	w.drawCell(0, 1, w.path, false)

	{
		w.drawCell(1, 0, "branch", false)
		msg, err := gitBranchName(ctx, w.path)
		if err != nil {
			msg = err.Error()
		}
		w.drawCell(1, 1, msg, err != nil)
	}
	{
		w.drawCell(2, 0, "commit", false)
		msg, err := gitShortCommit(ctx, w.path)
		if err != nil {
			msg = err.Error()
		}
		w.drawCell(2, 1, msg, err != nil)
	}
	{
		w.drawCell(3, 0, "update", false)
		msg, err := w.getLastUpdate()
		if err != nil {
			msg = err.Error()
		}
		w.drawCell(3, 1, msg, err != nil)
	}
}

func (w *WidgetInfraRepo) drawCell(row, col int, txt string, isErr bool) {
	cell := tview.NewTableCell(txt)

	if col%2 == 0 {
		cell.SetTextColor(tcell.ColorYellow).SetAlign(tview.AlignRight)
	} else {
		cell.SetTextColor(tcell.ColorWhite).SetAlign(tview.AlignLeft)
	}

	if isErr {
		cell.SetTextColor(tcell.ColorBlack)
		cell.SetBackgroundColor(tcell.ColorRed)
	}

	w.table.SetCell(row, col, cell)
}

func (w *WidgetInfraRepo) getLastUpdate() (string, error) {
	file, err := os.Open(w.lastUpdateFilePath)
	if err != nil {
		w.logger.With("error", err).Error("(getLastUpdate) failed os.Open")
		return "", err
	}

	defer func() {
		if err = file.Close(); err != nil {
			w.logger.With("error", err).Error("(getLastUpdate) failed file.Close")
		}
	}()

	b, err := io.ReadAll(file)
	if err != nil {
		w.logger.With("error", err).Error("(getLastUpdate) failed io.ReadAll")
		return "", err
	}

	raw := strings.TrimSpace(string(b))

	t, err := time.Parse("20060102", raw)
	if err != nil {
		w.logger.With("error", err).Error("(getLastUpdate) failed time.Parse")
		return "", err
	}

	return t.Format(time.DateOnly) + " (" + timeago.English.Format(t) + ")", nil
}
