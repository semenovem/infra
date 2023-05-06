#!/bin/sh

#************************************************************
# ssh-fwrd-msk1.service
# systemctl list-units --all --state=inactive
# systemctl daemon-reload
# systemctl reset-failed
# файлы сервисов: /usr/lib/systemd/system/...
#************************************************************

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

PREFIX_SERVICE_NAME="ssh-fwrd"
SYSTEMMD_DIR="/etc/systemd/system"
FILE_CONF="${ROOT:?}/ssh-fwrd.conf"

WORKING_DIRECTORY="$(__realpath__ "$ROOT")" || exit 1

[ ! -d "$SYSTEMMD_DIR" ] && echo "ERR: dir '${SYSTEMMD_DIR}' not exist" && exit 1

help() {
  echo "use: [ start | restart | stop | status | files ]"
}

tmpl() {
  # не работает на macos
  sed -i "s^{%\s*$2\s*%}^$3^gi" "$1"
}

getPathAutosshLogFile() {
  echo "${__CORE_STATE_DIR__}/${PREFIX_SERVICE_NAME}-$1.log"
}

getPathAutosshPidFile() {
  echo "${__CORE_STATE_DIR__}/${PREFIX_SERVICE_NAME}-$1.pid"
}

get_service_name() {
  echo "${PREFIX_SERVICE_NAME}-$1.service"
}

get_service_file_path() {
  echo "${SYSTEMMD_DIR}/$1"
}

getCmd() {
  echo "autossh -M 0 \
    -o 'ServerAliveInterval 30' \
    -o 'ServerAliveCountMax 3' \
    -o 'PubkeyAuthentication=yes' \
    -o 'StrictHostKeyChecking=false' \
    -o 'PasswordAuthentication=no' \
    -N $*"
}

create_file() {
  host=$1
  shift
  conns="$*"

  TMP_FILE=$(mktemp) || return 1
  cat "$FILE_CONF" >"$TMP_FILE" || return 1

  tmpl "$TMP_FILE" "envAutosshLogfile" "$(getPathAutosshLogFile "$host")" || return 1
  tmpl "$TMP_FILE" "envAutosshPidfile" "$(getPathAutosshPidFile "$host")" || return 1
  tmpl "$TMP_FILE" "workingDirectory" "$WORKING_DIRECTORY" || return 1
  tmpl "$TMP_FILE" "user" "$(id -un)" || return 1
  tmpl "$TMP_FILE" "group" "$(id -gn)" || return 1
  tmpl "$TMP_FILE" "execStart" "$(getCmd "$conns" "$host")" || return 1

  echo "$TMP_FILE"
}

start() {
  host=$1
  shift

  #  проверить, запущен ли процесс

  SERVICE_NAME="$(get_service_name $host)"
  [ -n "$__DRY__" ] && __info__ "запустить '${host}' '${SERVICE_NAME}'" && return 0

  TMP_FILE="$(create_file $host $*)" || return 1

  sudo mv "$TMP_FILE" "$(get_service_file_path "$SERVICE_NAME")" || return 1
  sudo systemctl daemon-reload || return 1
  sudo systemctl start "$SERVICE_NAME" || return 1
  sudo systemctl enable "$SERVICE_NAME" || return 1
}

stop() {
  host=$(echo "$1" | grep -Eio ".+[^(.service)]" | cut -c10-)

  SERVICE_NAME="$(get_service_name $host)"

  [ -n "$__DRY__" ] && __info__ "остановить '${SERVICE_NAME}'" && return 0

  sudo systemctl stop "$SERVICE_NAME" || return 1
  sudo systemctl disable "$SERVICE_NAME" || return 1
  sudo rm -f "$(get_service_file_path "$SERVICE_NAME")" || return 1
  sudo systemctl reset-failed
  sudo systemctl daemon-reload
}

ARG="$1"
[ -z "$ARG" ] && ARG="status"

case "$ARG" in
"start")
  pipe() {
    while read -r data; do
      start $data
    done
  }

  HOSTNAME=$(__get_hostname__) || exit 1

  __run_configurator__ ssh-remote-forward -host "$HOSTNAME" | pipe
  ;;

"stop")
  pipe() {
    while read -r data; do
      stop "$data"
    done
  }

  systemctl list-units "ssh-fwrd-*" --all | grep -E '^\s*ssh-fwrd-' | awk '{print $1}' | pipe
  ;;

"status") systemctl list-units "ssh-fwrd-*" --all ;;

"files")
  # TODO сделать просмотр файлов запущенных серсвисов
  # если запущенных нет - посмотреть новые файлы
  ;;

*)
  __err__ "unknown arg '$ARG'"
  help
  exit 1
  ;;
esac
