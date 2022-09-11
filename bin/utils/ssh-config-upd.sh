#!/bin/sh

# Запись файла ssh config

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_core/conf.sh"
. "${ROOT}/../_core/func.sh"
. "${ROOT}/../_core/logger.sh"

TARGET_FILE="${HOME}/.ssh/config"
SSH_CONFIG_FILE=$(mktemp) || exit 1
PREVIEW_FILE=

if [ -z "$__QUIET__" ]; then
  PREVIEW_FILE=$(mktemp) || exit 1
fi

sh "${ROOT}/ssh-config.sh" "$SSH_CONFIG_FILE" "$PREVIEW_FILE" || exit 1

[ -z "$__QUIET__" ] && cat "$PREVIEW_FILE"

if [ -z "$(cat "$SSH_CONFIG_FILE")" ]; then
  __warn__ "Нет данных для ssh config"

  __confirm__ "Удалить файл ssh конфигурации [${TARGET_FILE}] ?"
  [ $? -ne 0 ] && exit 0

  rm -f "$TARGET_FILE" || exit 1

  exit 0
fi

# Подтверждение при перезаписи файла
if [ -f "$TARGET_FILE" ]; then
  # Сравнить с текущим
  cmp --quiet "$TARGET_FILE" "$SSH_CONFIG_FILE"
  if [ $? -eq 0 ]; then
    __info__ "Содержимое ssh config [${TARGET_FILE}] не требует обновления"
    exit 0
  fi

  __confirm__ "файл ssh config [${TARGET_FILE}] уже существует, перезаписать ? "
  [ $? -ne 0 ] && __info__ "Отмена сохранения нового файла ssh config" && exit 0
fi

cat "$SSH_CONFIG_FILE" >"$TARGET_FILE" || exit 1

chmod 0644 "$TARGET_FILE"

__info__ "Записан новый файл ssh config [${TARGET_FILE}]"
