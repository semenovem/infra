#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

CONFIG_FILE="${ROOT}/../../../configs/mini-minidlna.conf"
PID_FILE="${HOME}/minidlna/minidlna.pid"
LOG_FILE="${HOME}/minidlna/logs/minidlna.log"

which minidlnad >/dev/null
[ $? -ne 0 ] && __err__ "not installed minidlna" && exit 1

running() {
  [ -f "$PID_FILE" ] && return 0
  HAS=$(ps -aux | grep -v grep | grep 'minidlnad -f') || return 1
  [ -n "$HAS" ]
}

case "$1" in
"start")
  running && __info__ "already running" && exit 0

  minidlnad -f "$CONFIG_FILE" -P "$PID_FILE" -R -r
  ;;

"stop")
  running
  [ $? -ne 0 ] && __info__ "already stopped" && exit 0

  [ -f "$PID_FILE" ] && kill -2 "$(cat "$PID_FILE")"
  ;;

"log") tail -f "$LOG_FILE" ;;

*) __info__ "use minidlna.sh [start | stop | log]" ;;
esac

exit 0

#-S $DAEMON_OPTS
