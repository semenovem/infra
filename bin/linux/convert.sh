#!/bin/sh

# Конвертация содержимого директории avi в mkv
# ffmpeg -fflags +genpts -i s01e01_Pilot.avi -c:v copy -c:a copy ~/tmp/film1.mkv

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_lib/core.sh" || exit 1

BASENAME=$(which basename) || exit 1
FFMPEG=$(which ffmpeg) || exit 1
DESTINATION=$1

[ -z "$DESTINATION" ] && __err__ "Destination directory not passed" && exit 1

if [ ! -d "$DESTINATION" ]; then
  __info__ "Create destination directory"
  mkdir "$DESTINATION" || exit 1
fi

__confirm__ "Директория назначения [${DESTINATION}]. Продолжить ?" || exit 0

# ---------------------------------------
# Подтверждение файлов для конвертации
if [ -z "$__YES__" ]; then
  __info__ "Файлы для конвертации:"
  pipe() {
    while read -r PATH; do
      $BASENAME $PATH
    done
  }
  find ./ -iname "*.avi" | pipe
fi


# ---------------------------------------
# Конвертация
__confirm__ "Продолжить ?" || exit 0

for PATH in $(find ./ -iname "*.avi"); do
  FILE_NAME=$($BASENAME $PATH ".avi")

  $FFMPEG -fflags +genpts -i "$PATH" -c:v copy -c:a copy "${DESTINATION%/}/${FILE_NAME}.mkv"
done
