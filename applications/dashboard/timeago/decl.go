// Copyright 2013 Simon HEGE. All rights reserved.
// Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

// timeago allows the formatting of time in terms of fuzzy timestamps.
// For example:
//
//	one minute ago
//	3 years ago
//	in 2 minutes
package timeago

import (
	"fmt"
	"strings"
	"time"
)

const (
	Day   time.Duration = time.Hour * 24
	Month time.Duration = Day * 30
	Year  time.Duration = Day * 365
)

type FormatPeriod struct {
	D    time.Duration
	One  string
	Many string
}

// Config allows the customization of timeago.
// You may configure string items (language, plurals, ...) and
// maximum allowed duration value for fuzzy formatting.
type Config struct {
	PastPrefix   string
	PastSuffix   string
	FuturePrefix string
	FutureSuffix string

	Periods []FormatPeriod

	Zero string
	Max  time.Duration //Maximum duration for using the special formatting.
	//DefaultLayout is used if delta is greater than the minimum of last period
	//in Periods and Max. It is the desired representation of the date 2nd of
	// January 2006.
	DefaultLayout string
}

// Predefined english configuration
var English = Config{
	PastPrefix:   "",
	PastSuffix:   " ago",
	FuturePrefix: "in ",
	FutureSuffix: "",

	Periods: []FormatPeriod{
		{time.Second, "about a second", "%d seconds"},
		{time.Minute, "about a minute", "%d minutes"},
		{time.Hour, "about an hour", "%d hours"},
		{Day, "one day", "%d days"},
		{Month, "one month", "%d months"},
		{Year, "one year", "%d years"},
	},

	Zero: "about a second",

	Max:           73 * time.Hour,
	DefaultLayout: "2006-01-02",
}

var Portuguese = Config{
	PastPrefix:   "há ",
	PastSuffix:   "",
	FuturePrefix: "daqui a ",
	FutureSuffix: "",

	Periods: []FormatPeriod{
		{time.Second, "um segundo", "%d segundos"},
		{time.Minute, "um minuto", "%d minutos"},
		{time.Hour, "uma hora", "%d horas"},
		{Day, "um dia", "%d dias"},
		{Month, "um mês", "%d meses"},
		{Year, "um ano", "%d anos"},
	},

	Zero: "menos de um segundo",

	Max:           73 * time.Hour,
	DefaultLayout: "02-01-2006",
}

var Spanish = Config{
	PastPrefix:   "hace ",
	PastSuffix:   "",
	FuturePrefix: "en ",
	FutureSuffix: "",

	Periods: []FormatPeriod{
		{time.Second, "un segundo", "%d segundos"},
		{time.Minute, "un minuto", "%d minutos"},
		{time.Hour, "una hora", "%d horas"},
		{Day, "un día", "%d días"},
		{Month, "un mes", "%d meses"},
		{Year, "un año", "%d años"},
	},

	Zero:          "menos de un segundo",
	Max:           73 * time.Hour,
	DefaultLayout: "02-01-2006",
}

var Chinese = Config{
	PastPrefix:   "",
	PastSuffix:   "前",
	FuturePrefix: "于 ",
	FutureSuffix: "",

	Periods: []FormatPeriod{
		{time.Second, "1 秒", "%d 秒"},
		{time.Minute, "1 分钟", "%d 分钟"},
		{time.Hour, "1 小时", "%d 小时"},
		{Day, "1 天", "%d 天"},
		{Month, "1 月", "%d 月"},
		{Year, "1 年", "%d 年"},
	},

	Zero: "1 秒",

	Max:           73 * time.Hour,
	DefaultLayout: "2006-01-02",
}

// Predefined french configuration
var French = Config{
	PastPrefix:   "il y a ",
	PastSuffix:   "",
	FuturePrefix: "dans ",
	FutureSuffix: "",

	Periods: []FormatPeriod{
		{time.Second, "environ une seconde", "moins d'une minute"},
		{time.Minute, "environ une minute", "%d minutes"},
		{time.Hour, "environ une heure", "%d heures"},
		{Day, "un jour", "%d jours"},
		{Month, "un mois", "%d mois"},
		{Year, "un an", "%d ans"},
	},

	Zero: "environ une seconde",

	Max:           73 * time.Hour,
	DefaultLayout: "02/01/2006",
}

// Predefined german configuration
var German = Config{
	PastPrefix:   "vor ",
	PastSuffix:   "",
	FuturePrefix: "in ",
	FutureSuffix: "",

	Periods: []FormatPeriod{
		{time.Second, "einer Sekunde", "%d Sekunden"},
		{time.Minute, "einer Minute", "%d Minuten"},
		{time.Hour, "einer Stunde", "%d Stunden"},
		{Day, "einem Tag", "%d Tagen"},
		{Month, "einem Monat", "%d Monaten"},
		{Year, "einem Jahr", "%d Jahren"},
	},

	Zero: "einer Sekunde",

	Max:           73 * time.Hour,
	DefaultLayout: "02.01.2006",
}

// Predefined turkish configuration
var Turkish = Config{
	PastPrefix:   "",
	PastSuffix:   " önce",
	FuturePrefix: "",
	FutureSuffix: " içinde",

	Periods: []FormatPeriod{
		{time.Second, "yaklaşık bir saniye", "%d saniye"},
		{time.Minute, "yaklaşık bir dakika", "%d dakika"},
		{time.Hour, "yaklaşık bir saat", "%d saat"},
		{Day, "bir gün", "%d gün"},
		{Month, "bir ay", "%d ay"},
		{Year, "bir yıl", "%d yıl"},
	},

	Zero: "yaklaşık bir saniye",

	Max:           73 * time.Hour,
	DefaultLayout: "02/01/2006",
}

// Korean support
var Korean = Config{
	PastPrefix:   "",
	PastSuffix:   " 전",
	FuturePrefix: "",
	FutureSuffix: " 후",

	Periods: []FormatPeriod{
		{time.Second, "약 1초", "%d초"},
		{time.Minute, "약 1분", "%d분"},
		{time.Hour, "약 한시간", "%d시간"},
		{Day, "하루", "%d일"},
		{Month, "1개월", "%d개월"},
		{Year, "1년", "%d년"},
	},

	Zero: "방금",

	Max:           10 * 365 * 24 * time.Hour,
	DefaultLayout: "2006-01-02",
}

// Format returns a textual representation of the time value formatted according to the layout
// defined in the Config. The time is compared to time.Now() and is then formatted as a fuzzy
// timestamp (eg. "4 days ago")
func (cfg Config) Format(t time.Time) string {
	return cfg.FormatReference(t, time.Now())
}

// FormatReference is the same as Format, but the reference has to be defined by the caller
func (cfg Config) FormatReference(t time.Time, reference time.Time) string {

	d := reference.Sub(t)

	if (d >= 0 && d >= cfg.Max) || (d < 0 && -d >= cfg.Max) {
		return t.Format(cfg.DefaultLayout)
	}

	return cfg.FormatRelativeDuration(d)
}

// FormatRelativeDuration is the same as Format, but for time.Duration.
// Config.Max is not used in this function, as there is no other alternative.
func (cfg Config) FormatRelativeDuration(d time.Duration) string {

	isPast := d >= 0

	if d < 0 {
		d = -d
	}

	s, _ := cfg.getTimeText(d, true)

	if isPast {
		return strings.Join([]string{cfg.PastPrefix, s, cfg.PastSuffix}, "")
	} else {
		return strings.Join([]string{cfg.FuturePrefix, s, cfg.FutureSuffix}, "")
	}
}

// Round the duration d in terms of step.
func round(d time.Duration, step time.Duration, roundCloser bool) time.Duration {

	if roundCloser {
		return time.Duration(float64(d)/float64(step) + 0.5)
	}

	return time.Duration(float64(d) / float64(step))
}

// Count the number of parameters in a format string
func nbParamInFormat(f string) int {
	return strings.Count(f, "%") - 2*strings.Count(f, "%%")
}

// Convert a duration to a text, based on the current config
func (cfg Config) getTimeText(d time.Duration, roundCloser bool) (string, time.Duration) {
	if len(cfg.Periods) == 0 || d < cfg.Periods[0].D {
		return cfg.Zero, 0
	}

	for i, p := range cfg.Periods {

		next := p.D
		if i+1 < len(cfg.Periods) {
			next = cfg.Periods[i+1].D
		}

		if i+1 == len(cfg.Periods) || d < next {

			r := round(d, p.D, roundCloser)

			if next != p.D && r == round(next, p.D, roundCloser) {
				continue
			}

			if r == 0 {
				return "", d
			}

			layout := p.Many
			if r == 1 {
				layout = p.One
			}

			if nbParamInFormat(layout) == 0 {
				return layout, d - r*p.D
			}

			return fmt.Sprintf(layout, r), d - r*p.D
		}
	}

	return d.String(), 0
}

// NoMax creates an new config without a maximum
func NoMax(cfg Config) Config {
	return WithMax(cfg, 9223372036854775807, time.RFC3339)
}

// WithMax creates an new config with special formatting limited to durations less than max.
// Values greater than max will be formatted by the standard time package using the defaultLayout.
func WithMax(cfg Config, max time.Duration, defaultLayout string) Config {
	n := cfg
	n.Max = max
	n.DefaultLayout = defaultLayout
	return n
}
