#!/bin/sh

# Конвертация содержимого директории avi в mkv
# https://trofimovdigital.ru/blog/convert-video-with-ffmpeg

# ffmpeg -fflags +genpts -i s01e01_Pilot.avi -c:v copy -c:a copy ~/tmp/film1.mkv
# ffmpeg -i filename.mkv -c:v copy -c:a copy output.avi
# ffmpeg -i "input.mkv" -f avi -c:v mpeg4 -b:v 4000k -c:a libmp3lame -b:a 320k "converted.avi"
# ffmpeg -i "input.mkv" -f avi -c:v mpeg4 -b:v 1000k -c:a copy "converted.avi"
# ffmpeg -i The.Big.Short.2015.HDRip.AVC.mkv -vcodec mpeg4  -b:v 1000k  -acodec mp3 The.Big.Short.2015.HDRip.AVC.avi
# -s 16cif
# -cpucount 5
# -vf scale=1920:1080  конвертация в 4к


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


  echo ">>>> $SRC_FILE"

#  FILE_NAME=$(basename "$SRC_FILE" ".avi")
#  DST_FILE="${DEST_DIR}/${FILE_NAME}.mkv"
#
#  ffmpeg -fflags +genpts -i "$SRC_FILE" -c:v copy -c:a copy "${DST_FILE}.mkv"
done
