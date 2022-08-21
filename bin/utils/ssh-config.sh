#!/bin/sh

# Запись файла ssh config

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_core/func.sh"
. "${ROOT}/../_core/role.sh"
. "${ROOT}/../_core/logger.sh"

__CFG_WORKSTATION__="${ROOT}/../../home/ssh/workstation.txt"
__CFG_SERVER__="${ROOT}/../../home/ssh/server.txt"
__CFG_LOCAL__="${ROOT}/../../home/ssh/local.txt"

ROLE=$(__core_role_get__) || (__err__ "Нет установленной роли машины" && exit 1)

SSH_CONFIG=
PREVIEW="Предварительный просмотр:\nКонфигурация для роли '$ROLE'"

concatF() {
  [ -n "$SSH_CONFIG" ] && SSH_CONFIG="${SSH_CONFIG}\n\n\n"
  SSH_CONFIG="${SSH_CONFIG}$(cat "$1")"

  # для предпросмотра того, что будет записано в ssh config
  [ -n "$PREVIEW" ] && PREVIEW="${PREVIEW}\n"
  PREVIEW="${PREVIEW}$(cat "$1" | head -3)\n....."
}

concatF "$__CFG_SERVER__"

case "$ROLE" in
"$__CORE_ROLE_HOME_SERVER_CONST__" | "$__CORE_ROLE_STANDBY_SERVER_CONST__")
  concatF "$__CFG_LOCAL__"
  ;;

"$__CORE_ROLE_WORKSTATION_CONST__")
  concatF "$__CFG_WORKSTATION__"
  concatF "$__CFG_LOCAL__"
  ;;
esac

echo "$PREVIEW"

[ -z "$SSH_CONFIG" ] && __warn__ "Нет данных для ssh config" && exit 1

# Проверка существования директории
if [ ! -d "${HOME}/.ssh" ]; then
  mkdir "${HOME}/.ssh" || exit 1
  chmod 0600 "${HOME}/.ssh" || exit 1
fi

# Подтверждение при перезаписи файла
if [ -f "${HOME}/.ssh/config" ]; then
  __confirm__ "файл конфигурации уже существует, перезаписать ? "
  [ $? -ne 0 ] && __info__ "Отмена сохранения нового файла ssh config" && exit 0
fi

echo "$SSH_CONFIG" >"${HOME}/.ssh/config" || exit 1

chmod 0644 "${HOME}/.ssh/config"
