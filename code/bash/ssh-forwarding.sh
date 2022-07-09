#!/bin/bash

BIN=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")

_CMD_=$1
_VERBOSE_=true
_LOGFILE="${BIN}/log-start.logs"

_SHELL_CMD_="ssh -fNR 4022:localhost:22 user@xxx.xxx.xxx.xxx"

function debug() {
  local s="[DEBUG] $*"
  [ -z "$_VERBOSE_" ] && return 0
  echo -e "$s" >>"$_LOGFILE"
}

function info() {
  local s="[INFO] $*"
  [ -z "$_VERBOSE_" ] && return 0
  echo -e "$s" >>"$_LOGFILE"
}

function err() {
  local s="[ERROR] $*"
  echo -e "$s" >>"$_LOGFILE"
}

function hasConn() {
  ps -aux | grep "$_SHELL_CMD_" | grep -q -v grep
}

function pidConn() {
  local res count
  res=$(ps -aux | grep "$_SHELL_CMD_" | grep -v grep | awk '{print $2}')
  count=$(ps -aux | grep "$_SHELL_CMD_" | grep -v grep | wc -l)
  [ "$count" -eq "0" ] && err "process not found" && return 1
  [ "$count" -gt "1" ] && err "more then one process found" && return 1
  echo "$res"
  return 0
}

function status() {
  hasConn &&
    echo "[STATUS] connection established" ||
    echo "[STATUS] connection not established"
}

case "$_CMD_" in
"--start")
  debug "$(date) __ args: $*)"
  hasConn && info "connection already established" && exit 0

  COUNT=0
  while true; do
    ((COUNT++))

    $_SHELL_CMD_ &&
      info "successful connection" &&
      exit 0

    [ "$COUNT" -gt "5" ] && err "connection failed" && exit 1
    info "waiting before next connection attempt (attempt number: ${COUNT})"
    sleep 15
  done
  ;;

"--stop")
  debug "$(date) __ args: $*)"
  pid=$(pidConn) || exit 1
  echo "killing: $pid"
  kill -1 "$pid"
  sleep 1
  kill -9 "$pid" 2> /dev/null
  ;;

"--status") status ;;
*)
  [ "$_CMD_" ] && echo "unknown command type '${_CMD_}'. use --[start|stop|status]"
  status
  ;;
esac
