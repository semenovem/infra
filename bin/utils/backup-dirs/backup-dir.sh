#!/bin/sh

# -----------------------------------------------
# Перебирает директорию в поисках .git директорий - архивирует на удаленный хост
# Если директория не .git и весит меньше `SIZE_PACK_MAX` Mb - архивируем
# Если директория .git не найдена и вниз спускаться уже нельзя (depth = 0) - архивируем
# $1 - адрес хоста для подключения по ssh
# $2 - локальная директория которую нужно заархивировать на удаленный хост
# $3 - путь на целевой машине для файла архива
# $4 - уровень вложенности поиска директорий .git
# -----------------------------------------------

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

# Входные аргументы
SRC_DIR=$1
HOST=$2
DST_DIR=$3
MAX_DEPTH=$4 # на сколько директорий можно проваливаться вглубь

SIZE_PACK_MAX=100 # максимальный размер директории которая не является репозиторием

[ -z "$SRC_DIR" ] && __err__ "не передан аргумент (архивируемая директория) \$1" && exit 1
SRC_DIR=$(__absolute_path__ "$SRC_DIR")

MAX_DEPTH=$(echo "$MAX_DEPTH" | grep -iEo '[0-9]*')
[ -z "$MAX_DEPTH" ] && MAX_DEPTH=0

ssh "$HOST" "mkdir -p ${DST_DIR}" || exit 1 # Создать директорию на удаленном хосте

copy_via_ssh() {
# TODO добавить проверку последних измененных файлов и архивировать только их
# find /home/captain -type f -mmin -30
# find /home/captain -type d -mmin -30

  DIR_NAME=$(basename "$1")
  sh "${ROOT}/archive-dir.sh" "$HOST" "$1" "${DST_DIR}/${DIR_NAME}.tar.gz"
}

for DIR in "$SRC_DIR"/*; do
  [ ! -d "$DIR" ] && continue

  if [ -d "${DIR}/.git" ]; then
    copy_via_ssh "$DIR"
    continue
  fi

  SIZE="$(du -sm "$DIR" | awk '{print $1}')"
  if [ "$SIZE" -lt "$SIZE_PACK_MAX" ]; then
    copy_via_ssh "$DIR"
    continue
  fi

  if [ "$MAX_DEPTH" -gt 0 ]; then
    sh "$0" "$DIR" "$HOST" "${DST_DIR}/$(basename "$DIR")" "$((MAX_DEPTH - 1))"
    continue
  fi

  copy_via_ssh "$DIR"

done
