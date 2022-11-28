#!/bin/sh

# Подготовка файла ssh authorized_keys
# $1 - роль, для которой собрать файл

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_lib/core.sh" || exit 1
. "${ROOT}/../_lib/role.sh" || exit 1

ROLE=$1

case "$ROLE" in
"$__CORE_ROLE_PROXY_SERVER_CONST__") __config__ "" "cpi_${cpi}_ssh_main_pub_key" ;;

"$__CORE_ROLE_MINI_SERVER_CONST__" | \
  "$__CORE_ROLE_HOME_SERVER_CONST__" | \
  "$__CORE_ROLE_STANDBY_SERVER_CONST__" | \
  "$__CORE_ROLE_WORKSTATION_CONST__")
  __config__ "" "cpi_${cpi}_pub_key"
  ;;

*)
esac


pipe() {
  while read -r cpi; do

    case "$ROLE" in
    "$__CORE_ROLE_PROXY_SERVER_CONST__") __config__ "" "cpi_${cpi}_ssh_main_pub_key" ;;

    "$__CORE_ROLE_MINI_SERVER_CONST__" | \
      "$__CORE_ROLE_HOME_SERVER_CONST__" | \
      "$__CORE_ROLE_STANDBY_SERVER_CONST__" | \
      "$__CORE_ROLE_WORKSTATION_CONST__")
      __config__ "" "cpi_${cpi}_pub_key"
      ;;

    *)
      __err__ "Получена не известная роль '${ROLE}'"
      exit 1
      ;;
    esac

  done
}

sh "${ROOT}/api-config.sh" "get-cpis-by-role" "$ROLE" | pipe
echo "ret = $?"
#__config__ "" "cpi"

exit

SOURCE_FILE="${ROOT}/../../home/ssh/keys-pub.txt"

[ ! -f "$SOURCE_FILE" ] && __err__ "нет файла с публичными ключами [${SOURCE_FILE}]" && exit 1

AUTHORIZED_KEYS_FILE=$1
PREVIEW_FILE=$2

[ -z "$AUTHORIZED_KEYS_FILE" ] && __err__ "не передан агрумент - файл для \$1" && exit 1

[ ! -f "$AUTHORIZED_KEYS_FILE" ] &&
  __err__ "переданый аргумент \$1 должен быть файлом = '${AUTHORIZED_KEYS_FILE}'" && exit 1

[ -n "$PREVIEW_FILE" ] && [ ! -f "$PREVIEW_FILE" ] &&
  __err__ "переданный аргумент \$2 должен быть файлом = '${PREVIEW_FILE}'" && exit 1

ROLE=$(__core_role_get__)
[ $? -ne 0 ] && __err__ "Нет установленной роли машины" && exit 1

if [ -n "$PREVIEW_FILE" ]; then
  echo "Предварительный просмотр: Ключи ssh authorized_keys для роли '$ROLE'" >"$PREVIEW_FILE"
fi

add() {
  grep -iA 1 "$1" "$SOURCE_FILE" | grep -viE '(^\-|^#|^$)' >>"$AUTHORIZED_KEYS_FILE"
  [ -n "$PREVIEW_FILE" ] && echo "$1" >>"$PREVIEW_FILE"
}

case "$ROLE" in
"$__CORE_ROLE_PROXY_SERVER_CONST__")
  add "$__CORE_ROLE_HOME_SERVER_CONST__"
  add "$__CORE_ROLE_STANDBY_SERVER_CONST__"
  add "$__CORE_ROLE_PROXY_SERVER_CONST__"
  add "$__CORE_ROLE_WORKSTATION_CONST__"
  add "$__CORE_ROLE_MINI_SERVER_CONST__"
  ;;

"$__CORE_ROLE_MINI_SERVER_CONST__" | "$__CORE_ROLE_HOME_SERVER_CONST__")
  add "$__CORE_ROLE_WORKSTATION_CONST__"
  ;;

"$__CORE_ROLE_STANDBY_SERVER_CONST__")
  add "$__CORE_ROLE_WORKSTATION_CONST__"
  add "$__CORE_ROLE_HOME_SERVER_CONST__"
  add "$__CORE_ROLE_STANDBY_SERVER_CONST__"
  ;;

"$__CORE_ROLE_WORKSTATION_CONST__")
  __info__ "для роли '${ROLE}' нет предустановленных ключей"
  ;;

*)
  __err__ "Получена не известная роль '${ROLE}'"
  exit 1
  ;;
esac

exit 0
