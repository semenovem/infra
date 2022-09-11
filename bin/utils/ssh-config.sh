#!/bin/sh

# подготовка файла ssh config или preview
# $1 - файл ssh config
# $2 - файл предпросмотра

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_core/role.sh"
. "${ROOT}/../_core/logger.sh"

SSH_CONFIG_FILE=$1
PREVIEW_FILE=$2

[ -z "$SSH_CONFIG_FILE" ] && __err__ "не передан агрумент - файл для \$1" && exit 1

[ ! -f "$SSH_CONFIG_FILE" ] &&
  __err__ "переданый аргумент \$1 должен быть файлом = '${SSH_CONFIG_FILE}'" && exit 1

[ -n "$PREVIEW_FILE" ] && [ ! -f "$PREVIEW_FILE" ] &&
  __err__ "переданный аргумент \$2 должен быть файлом = '${PREVIEW_FILE}'" && exit 1

__CFG_WORKSTATION__="${ROOT}/../../home/ssh/workstation.txt"
__CFG_SERVER__="${ROOT}/../../home/ssh/server.txt"
__CFG_LOCAL__="${ROOT}/../../home/ssh/local.txt"
CONTENT=

ROLE=$(__core_role_get__)
[ $? -ne 0 ] && __err__ "Нет установленной роли машины" && exit 1

[ -n "$PREVIEW_FILE" ] &&
  echo "Предварительный просмотр: конфигурация для роли '$ROLE'" >"$PREVIEW_FILE"

add() {
  {
    [ -n "$CONTENT" ] && echo "" && echo ""
    cat "$1"
  } >>"$SSH_CONFIG_FILE"
  CONTENT=1

  # для предпросмотра того, что будет записано в ssh config
  [ -n "$PREVIEW_FILE" ] &&
    {
      cat "$1" | head -3
      echo "..."
    } >>"$PREVIEW_FILE"
}

case "$ROLE" in
"$__CORE_ROLE_HOME_SERVER_CONST__" | "$__CORE_ROLE_STANDBY_SERVER_CONST__")
  add "$__CFG_SERVER__"
  add "$__CFG_LOCAL__"
  ;;

"$__CORE_ROLE_WORKSTATION_CONST__")
  add "$__CFG_SERVER__"
  add "$__CFG_WORKSTATION__"
  add "$__CFG_LOCAL__"
  ;;

"$__CORE_ROLE_PROXY_SERVER_CONST__")
  add "$__CFG_SERVER__"
  ;;

*)
  __err__ "Получена не известная роль '${ROLE}'"
  exit 1
  ;;
esac

exit 0
