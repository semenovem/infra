#!/bin/bash

#************************************************************
# ssh-forwarding.service
#
# DEPLOYMENT
# ENV_DAEMON_PID_FILE - пусть к файлу pid процесса сервиса
#
#sudo vim /etc/systemd/system/crone-shell.service
#sudo systemctl daemon-reload
#sudo systemctl start "crone-shell.service"
#sudo systemctl stop "crone-shell.service"
#sudo systemctl enable "crone-shell.service"
#sudo systemctl status crone-shell
#************************************************************

__BIN__=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")
source "${__BIN__:?}/common.sh"

__SERVICE_NAME__="ssh-fwrd"
__SYSTEMMD_DIR__="/etc/systemd/system"

__FILE_CONF__="${__BIN__:?}/${__SERVICE_NAME__}.conf"
__WORKING_DIRECTORY__="$__BIN__"
__USER__="$(whoami)"
__GROUP__="$(whoami)"
__PROPS_FILE__="${__BIN__}/${__SERVICE_NAME__}.properties"
__HOSTNAME__=$(cat "/etc/hostname")

__OPER__=
__TMP_FILE__=
__DEBUG__=
__ERR__=

[ ! -d "$__SYSTEMMD_DIR__" ] && echo "ERR: dir '${__SYSTEMMD_DIR__}' not exist"

function help {
  echo "use: [ start | restart | stop | status | files ]"
}

function info {
  echo "[INFO] [$(date)] $*"
}

function debug {
  [ -z "$__DEBUG__" ] && return 0
  echo "[DEBU] [$(date)] $*"
}

function tmpl {
  local a=$1 b=$2
  sed -i "s^{%\s*${a}\s*%}^${b}^gi" "$__TMP_FILE__"
}

function getPathAutosshLogFile {
  local host=$1
  echo "${__SELF_SYSCTL_STATE_DIR__}/${__SERVICE_NAME__}-${host}.log"
}

function getPathAutosshPidFile {
  local host=$1
  echo "${__SELF_SYSCTL_STATE_DIR__}/${__SERVICE_NAME__}-${host}.pid"
}

function getCmd {
  local host=$1 forward=$2
  echo "autossh -M 0 \
    -o 'ServerAliveInterval 30' \
    -o 'ServerAliveCountMax 3' \
    -o 'PubkeyAuthentication=yes' \
    -o 'StrictHostKeyChecking=false' \
    -o 'PasswordAuthentication=no' \
    -NR ${forward} $host"
}

function action {
  local oper=$1 host=$2 port=$3 sshPort=$4 forward query item serviceName file sysctlFile
  forward="${port}:127.0.0.1:${sshPort}"
  serviceName="${__SERVICE_NAME__}-${host}.service"

  debug ">>> oper=$oper  p=$port  h=$host  sshPort=$sshPort  serviceName=$serviceName"

  case "$oper" in
  "start" | "restart" | "files")
    file=$(mktemp) || return 1
    __TMP_FILE__="$file"
    cat "$__FILE_CONF__" >"$file" || return 1

    tmpl "envAutosshLogfile" "$(getPathAutosshLogFile "$host")"
    tmpl "envAutosshPidfile" "$(getPathAutosshPidFile "$host")"
    tmpl "workingDirectory" "$__WORKING_DIRECTORY__"
    tmpl "user" "$__USER__"
    tmpl "group" "$__GROUP__"
    tmpl "execStart" "$(getCmd "$host" "$forward")"

    sysctlFile="${__SYSTEMMD_DIR__}/${serviceName}"
    ;;
  esac

  case "$oper" in
  "start")
    sudo mv "$file" "$sysctlFile" || exit 1
    sudo systemctl daemon-reload
    sudo systemctl start "$serviceName"
    sudo systemctl enable "$serviceName"
    ;;

  "stop")
    sudo systemctl stop "$serviceName"
    sudo systemctl disable "$serviceName"
    sudo systemctl daemon-reload
    sudo rm -f "$sysctlFile"
    sudo systemctl list-units --all --state=inactive
    ;;

  "reload")
    action "stop" "$host" "$port" "$sshPort"
    action "start" "$host" "$port" "$sshPort"
    ;;

  "status")
    query=$(sudo systemctl status "$serviceName" 2>&1)
    info "[status for '${forward} $host'] ${query}"
    ;;

  "files")
    echo -e "\n"
    cat "$file"
    ;;
  esac
}

function readProps {
  local row defaultHosts port sshPort hosts host passed

  while read row; do
    echo "$row" | grep -q -iE '^#' && continue
    [ -z "$row" ] && continue

    echo "$row" | grep -q -iE '^hosts'
    if [ $? -eq 0 ]; then
      defaultHosts=$(echo "$row" | sed "s/^hosts\s*//i")
      continue
    fi

    echo "$row" | grep -q -iE "^${__HOSTNAME__}" || continue

    hosts=$(echo "$row" | awk '{print $4,$5,$6,$7,$8,$9,$10}' | xargs)
    [ -z "$hosts" ] && hosts="$defaultHosts"
    port=$(echo "$row" | awk '{print $2}')
    sshPort=$(echo "$row" | awk '{print $3}')

    for host in $hosts; do
      passed=1
      action "$__OPER__" "$host" "$port" "$sshPort"
    done

  done <"$__PROPS_FILE__"

  if [ -z "$passed" ]; then
    info "no match found for hostname '${__HOSTNAME__}'"
  fi
}

for p in "$@"; do
  case $p in
  "start") __OPER__="start" ;;
  "stop") __OPER__="stop" ;;
  "reload") __OPER__="reload" ;;
  "status") __OPER__="status" ;;
  "files") __OPER__="files" ;;
  "debug" | "-debug" | "--debug") __DEBUG__="1" ;;
  *)
    __ERR__=1
    info "unknown arg '$p'"
    ;;
  esac
done

[ "$__ERR__" ] && help && exit 1
[ -z "$__OPER__" ] && __OPER__="status"

readProps
