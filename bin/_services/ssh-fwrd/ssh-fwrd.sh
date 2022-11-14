#!/bin/bash

#************************************************************
# ssh-forwarding.service
# sudo systemctl list-units --all --state=inactive
# sudo systemctl daemon-reload
# sudo systemctl reset-failed
#************************************************************

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_core/conf.sh" || exit 1

__SERVICE_NAME__="ssh-fwrd"
__SYSTEMMD_DIR__="/etc/systemd/system"

__FILE_CONF__="${ROOT:?}/configs/${__SERVICE_NAME__}.conf"
__WORKING_DIRECTORY__="$(__realpath__ "$ROOT")" || exit 1
__USER__="$(whoami)"
__GROUP__="$(whoami)"
__PROPS_FILE__="${ROOT}/configs/${__SERVICE_NAME__}.properties"
__HOSTNAME__=$(cat "/etc/hostname")

__OPER__=
__TMP_FILE__=
__DEBUG__=
__ERR__=

[ ! -d "$__SYSTEMMD_DIR__" ] && echo "ERR: dir '${__SYSTEMMD_DIR__}' not exist"

function help {
  echo "use: [ start | restart | stop | status | files ]"
}

function debug {
  [ -z "$__DEBUG__" ] && return 0
  __debug__ "$*"
}

function tmpl {
  local a=$1 b=$2
  # не работает на macos
  sed -i "s^{%\s*${a}\s*%}^${b}^gi" "$__TMP_FILE__"
}

function getPathAutosshLogFile {
  local host=$1
  echo "${__CORE_CONF_STATE_DIR__}/${__SERVICE_NAME__}-${host}.log"
}

function getPathAutosshPidFile {
  local host=$1
  echo "${__CORE_CONF_STATE_DIR__}/${__SERVICE_NAME__}-${host}.pid"
}

function getCmd {
  local host=$1 conns=$2 a it

  for it in $conns; do
    a="${a} -R ${it}"
  done

  echo "autossh -M 0 \
    -o 'ServerAliveInterval 30' \
    -o 'ServerAliveCountMax 3' \
    -o 'PubkeyAuthentication=yes' \
    -o 'StrictHostKeyChecking=false' \
    -o 'PasswordAuthentication=no' \
    -N ${a} $host"
}

function action {
  local oper=$1 host=$2 ports=$3 rem loc query item serviceName file sysctlFile it conns
  serviceName="${__SERVICE_NAME__}-${host}.service"
  sysctlFile="${__SYSTEMMD_DIR__:?}/${serviceName:?}"

  debug ">>> oper=$oper h=$host p=$ports c=$conns serviceName=$serviceName"

  for it in $ports; do
    rem=$(echo "$it" | grep -iE -o "^[^:]+")
    loc=$(echo "$it" | grep -iE -o "[^:]+$")
    conns="${conns} ${rem}:127.0.0.1:${loc}"
  done

  case "$oper" in
  "start" | "restart" | "files")
    file=$(mktemp) || return 1
    __TMP_FILE__="$file"
    cat "$__FILE_CONF__" >"$file" || return 1

    tmpl "envAutosshLogfile" "$(getPathAutosshLogFile "$host")" || return 1
    tmpl "envAutosshPidfile" "$(getPathAutosshPidFile "$host")" || return 1
    tmpl "workingDirectory" "$__WORKING_DIRECTORY__" || return 1
    tmpl "user" "$__USER__" || return 1
    tmpl "group" "$__GROUP__" || return 1
    tmpl "execStart" "$(getCmd "$host" "$conns")" || return 1
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
    sudo rm -f "$sysctlFile"
    sudo systemctl reset-failed
    sudo systemctl daemon-reload
    ;;

  "status")
    query=$(sudo systemctl status "$serviceName" 2>&1)
    __info__ "[status for '${conns} $host'] ${query}"
    ;;

  "files")
    echo -e "\n"
    cat "$file"
    ;;

  "dry")
    echo -e "${host} ${conns}"
    ;;
  esac
}

function readProps {
  local row defaultHosts ports port hosts host count it map
  declare -A map

  while read row; do
    echo "$row" | grep -q -iE '^#' && continue
    [ -z "$row" ] && continue

    echo "$row" | grep -q -iE '^hosts'
    if [ $? -eq 0 ]; then
      defaultHosts=$(echo "$row" | sed "s/^hosts\s*//i")
      continue
    fi

    echo "$row" | grep -q -iE "^${__HOSTNAME__}" || continue

    count=0
    hosts=
    ports=
    for it in $row; do
      ((count++))
      [ "$count" -eq 1 ] && continue
      echo "$it" | grep ":" -q && ports="${ports} ${it}" || hosts="${hosts} ${it}"
    done

    [ -z "$hosts" ] && hosts="$defaultHosts"

    for host in $hosts; do
      map["$host"]+="$ports"
    done
  done <"$__PROPS_FILE__"

  for host in "${!map[@]}"; do
    action "$__OPER__" "$host" "${map[$host]}"
  done

  [ "${#map[*]}" -eq 0 ] && __info__ "no match found for hostname '${__HOSTNAME__}'"
}

for p in "$@"; do
  case $p in
  "start") __OPER__="start" ;;
  "stop") __OPER__="stop" ;;
  "restart") __OPER__="restart" ;;
  "status") __OPER__="status" ;;
  "files") __OPER__="files" ;;
  "dry") __OPER__="dry" ;;
  *"debug") __DEBUG__="1" ;;
  *)
    __ERR__=1
    __info__ "unknown arg '$p'"
    ;;
  esac
done

[ "$__ERR__" ] && help && exit 1
[ -z "$__OPER__" ] && __OPER__="status"

case "$__OPER__" in
"status")
  #    systemctl list-units "ssh-fwrd-*" --all | grep -E '^\s*ssh-fwrd-'
  systemctl list-units "ssh-fwrd-*" --all
  ;;
"__del") ;;

*) readProps ;;
esac