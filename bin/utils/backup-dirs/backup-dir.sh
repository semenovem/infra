#!/bin/sh

# sh /Users/jon/_environment/bin/utils/backup-dirs/backup-dir.sh _dev "home" "/mnt/soft/backup/laptop-16inno/09" 1
# sh /Users/jon/_environment/bin/utils/backup-dirs/backup-dir.sh _dev "evg@192.168.1.200" "/home/evg/backup/laptop-16inno/09/dev" 1
# Вернет ошибку [10] если директории с .git (репозитории) не будут найдены

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

# указать копируемые директории
# куда копировать

# пройти по директориям - заархивировать - скопировать

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



#[ ! -d "$SRC_DIR" ] && __err__ "путь ${SRC_DIR} не является директорией" && exit 1

#find "$SRC_DIR" -maxdepth 1 -type d

# Попробовать подключится к удаленному серверу
#ssh "$HOST" ls >/dev/null
#[ $? -ne 0 ] && __err__ "ошибка подключения к host=${HOST}" && exit 1

#exit
copy_via_ssh() {
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
