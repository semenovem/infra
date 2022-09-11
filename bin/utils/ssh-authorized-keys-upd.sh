#!/bin/sh

# Подготовка авторизованных ключей

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_core/conf.sh"
. "${ROOT}/../_core/func.sh"
. "${ROOT}/../_core/role.sh"
. "${ROOT}/../_core/logger.sh"

TARGET_FILE="${HOME}/.ssh/authorized-keys"

AUTHORIZED_KEYS_FILE=$(mktemp) || exit 1
PREVIEW_FILE=$(mktemp) || exit 1

sh "${ROOT}/ssh-authorized-keys.sh" "$AUTHORIZED_KEYS_FILE" "$PREVIEW_FILE" || exit 1

if [ -z "$(cat "$AUTHORIZED_KEYS_FILE")" ]; then
  __warn__ "Нет данных"
  __confirm__ "Удалить файл ssh ключей '${TARGET_FILE}' ?"
  [ $? -ne 0 ] && exit 0

  rm -f "$TARGET_FILE" || exit 1

  exit 0
fi

[ -n "$PREVIEW_FILE" ] && cat "$PREVIEW_FILE"

if [ -f "$TARGET_FILE" ]; then
  # Сравнить с текущим
  cmp --quiet "$TARGET_FILE" "$AUTHORIZED_KEYS_FILE"
  if [ $? -eq 0 ]; then
    __info__ "Содержимое ssh authorized_keys [${TARGET_FILE}] не требует обновления"
    exit 0
  fi

  __confirm__ "файл ssh authorized_keys [${TARGET_FILE}] уже существует, перезаписать ? "

  [ $? -ne 0 ] && __info__ "Отмена сохранения нового файла ssh authorized_keys" && exit 0
fi

cat "$AUTHORIZED_KEYS_FILE" >"$TARGET_FILE" || exit 1

chmod 0600 "$TARGET_FILE"

__info__ "Записан новый файл ssh authorized_keys [${TARGET_FILE}]"
