#!/bin/sh

# -----------------------------------------------
# Архивирование и копирование на удаленный сервер
# $1 - адрес хоста для подключения по ssh
# $2 - локальная директория которую нужно заархивировать и скопировать
# $3 - путь на целевой машине для файла архива
# -----------------------------------------------

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

# Входные аргументы
HOST=$1
SRC_DIR=$2
DST_FILE=$3

[ -z "$HOST" ] && __err__ "не передан аргумент (данные хоста для подключения по ssh) \$1" && exit 1
[ -z "$SRC_DIR" ] && __err__ "не передан аргумент (архивируемая директория) \$2" && exit 1
[ -z "$DST_FILE" ] && __err__ "не передан аргумент (куда копировать) \$3" && exit 1
[ ! -d "$SRC_DIR" ] && __err__ "путь ${SRC_DIR} не является директорией" && exit 1

which tar >/dev/null || __err__ "не установлена утилита tar"
[ $? -ne 0 ] && exit 1

__info__ "tar [${SRC_DIR}] and ssh to ssh [${DST_FILE}]"

FILE="${DST_FILE}.downloading"

cd "$(dirname "$SRC_DIR")" &&
  tar zcf - "$(basename "$SRC_DIR")" |
  ssh "$HOST" "cat > ${FILE} && mv ${FILE} ${DST_FILE}"