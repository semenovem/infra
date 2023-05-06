#!/bin/sh

# Подготовка авторизованных ключей

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1
. "${ROOT}/../../_lib/role.sh" || exit 1

TARGET_FILE="${HOME}/.ssh/authorized_keys"

ROLE=$(__core_role_get__)
__debug__ "role: ${ROLE}"

PUB_KEYS=$(__run_configurator__ ssh-authorized-keys -role "$ROLE") || exit 1

if [ -z "$PUB_KEYS" ]; then
  __info__ "нет ключей для добавления"

  if [ -f "$TARGET_FILE" ]; then
    __confirm__ "Удалить файл ssh ключей [${TARGET_FILE}] ?"
    [ $? -ne 0 ] && exit 0

    rm -f "$TARGET_FILE" || exit 1
  fi

  exit 0
fi

pipe() {
  while read -r data; do
    echo ">> $data" | grep -Eio "[^=]+$"
  done
}

__info__ "Ключи для добавления в [$TARGET_FILE]: "
echo "$PUB_KEYS" | pipe

__confirm__ "Добавить публичные ssh ключи в [${TARGET_FILE}] ?"
[ $? -ne 0 ] && exit 0

echo "$PUB_KEYS" >"$TARGET_FILE" || exit 1
chmod 0600 "$TARGET_FILE"
__info__ "Записан новый файл ssh authorized_keys [${TARGET_FILE}]"
