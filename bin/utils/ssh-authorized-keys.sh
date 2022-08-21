#!/bin/sh

# Подготовка авторизованных ключей

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_core/func.sh"
. "${ROOT}/../_core/role.sh"
. "${ROOT}/../_core/logger.sh"

AUTHORIZED_KEYS_FILE="${ROOT}/../../home/ssh/keys-pub.txt"

[ ! -f "$AUTHORIZED_KEYS_FILE" ] &&
  __err__ "Нет файла с публичными ключами '$AUTHORIZED_KEYS_FILE'" &&
  ecit 1

ROLE=$(__core_role_get__) || (__err__ "Нет установленной роли машины" && exit 1)

AUTHORIZED_KEYS=
PREVIEW="Предварительный просмотр:\nКлючи authorized_keys для роли '$ROLE'\n"

add() {
  keys=$(grep -iA 1 "$1" "$AUTHORIZED_KEYS_FILE" | grep -viE '(^\-|^#|^$)')
  AUTHORIZED_KEYS="${AUTHORIZED_KEYS}${keys}\n\n"

  PREVIEW="${PREVIEW}- $1\n"
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
esac

echo "$PREVIEW"

[ -z "$AUTHORIZED_KEYS" ] && __warn__ "Нет данных" && exit 1

# Проверка существования директории
if [ ! -d "${HOME}/.ssh" ]; then
  mkdir "${HOME}/.ssh" || exit 1

  chmod 0600 "${HOME}/.ssh" || exit 1
fi

# Подтверждение при перезаписи файла
if [ -f "${HOME}/.ssh/authorized_keys" ]; then
  __confirm__ "файл authorized_keys уже существует, перезаписать ? "

  [ $? -ne 0 ] && __info__ "Отмена сохранения нового файла authorized_keys" && exit 0
fi

echo "$AUTHORIZED_KEYS" >"${HOME}/.ssh/authorized_keys" || exit 1

chmod 0600 "${HOME}/.ssh/authorized_keys"
