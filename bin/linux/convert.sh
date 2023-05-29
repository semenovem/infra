#!/bin/sh

# Конвертация содержимого директории avi в mkv
# ffmpeg -fflags +genpts -i s01e01_Pilot.avi -c:v copy -c:a copy ~/tmp/film1.mkv

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_lib/core.sh" || exit 1

which basename
[ $? -ne 0 ] && __err__ "not install [basename]" && exit 1

which ffmpeg
[ $? -ne 0 ] && __err__ "not install [ffmpeg]" && exit 1

DEST_DIR=$1
[ -z "$DEST_DIR" ] && __err__ "destination directory not passed" && exit 1

DEST_DIR=$(__realpath__ "$DEST_DIR")

if [ ! -d "$DEST_DIR" ]; then
  __info__ "Create destination directory"
  mkdir "$DEST_DIR" || exit 1
fi

__confirm__ "Destination directory [ ${DEST_DIR} ] continue ?" || exit 0

# ---------------------------------------
# Подтверждение файлов для конвертации
if [ -z "$__YES__" ]; then
  __info__ "Files to convert:"

  for SRC_FILE in "./"*.avi; do
    basename "$SRC_FILE"
  done
fi

# ---------------------------------------
# Конвертация
__confirm__ "Continue ?" || exit 0

for SRC_FILE in "./"*.avi; do
  FILE_NAME=$(basename "$SRC_FILE" ".avi")
  DST_FILE="${DEST_DIR}/${FILE_NAME}.mkv"

  ffmpeg -fflags +genpts -i "$SRC_FILE" -c:v copy -c:a copy "${DST_FILE}.mkv"
done
