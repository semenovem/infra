#!/bin/sh

# Подготовка авторизованных ключей

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_core/conf.sh"
. "${ROOT}/../_core/func.sh"
. "${ROOT}/../_core/role.sh"
. "${ROOT}/../_core/logger.sh"

SOURCE_FILE="${ROOT}/../../home/ssh/keys-pub.txt"
TARGET_FILE="${HOME}/.ssh/authorized_keys"
AUTHORIZED_KEYS_FILE=$(mktemp) || exit 1
PREVIEW=

[ ! -f "$SOURCE_FILE" ] &&
  __err__ "Нет файла с публичными ключами '$SOURCE_FILE'" &&
  exit 1

ROLE=$(__core_role_get__)
[ $? -ne 0 ] && __err__ "Нет установленной роли машины" && exit 1

add() {
  {
    grep -iA 1 "$1" "$SOURCE_FILE" | grep -viE '(^\-|^#|^$)'
    echo ""
  } >>"$AUTHORIZED_KEYS_FILE"

  PREVIEW="${PREVIEW} $1"
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

if [ -z "$(cat "$AUTHORIZED_KEYS_FILE")" ]; then
  __warn__ "Нет данных"
  __confirm__ "Удалить файл ssh ключей '${TARGET_FILE}' ?"
  [ $? -ne 0 ] && exit 0

  rm -f "$TARGET_FILE" || exit 1

  exit 0
fi

echo "Предварительный просмотр: Ключи ssh authorized_keys для роли '$ROLE'"
for IT in $PREVIEW; do
  echo "-- $IT"
done

cat "$AUTHORIZED_KEYS_FILE"

# Подтверждение при перезаписи файла
if [ -f "$TARGET_FILE" ]; then
  __confirm__ "файл ssh ключей '${TARGET_FILE}' уже существует, перезаписать ? "

  [ $? -ne 0 ] && __info__ "Отмена сохранения нового файла ssh authorized_keys" && exit 0
fi

cat "$AUTHORIZED_KEYS_FILE" >"$TARGET_FILE" || exit 1

chmod 0600 "$TARGET_FILE"

__info__ "Записан новый файл ssh authorized_keys [${TARGET_FILE}]"
