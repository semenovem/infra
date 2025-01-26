#!/bin/sh

# для evg отправка последних видео-данных на удаленный сервер
# * * * * * sh /home/evg/_infra/dc/home/crone/xeoma-last-video.sh >> ~/logs/xeoma-last-video.log 2>&1

mkdir -p ~/logs

echo "-------------"

# $1 - path to file
# $2 - max size in bytes
# $3 - optional - number of files, default = 1
func_logs_maintain() {
  [ -f $1 ] || return 0
  size="$(stat --printf="%s" "$1")"
  [ "$size" -lt $2 ] && return 0

  ind="$3"
  [ -z "$ind" ] && ind=2
  ind=$((ind-1))
  if [ "$ind" -le "0" ]; then : > $1; return 0; fi

  prev_file=
  while [ "$ind" -ge "0" ]; do
    f="$1"
    [ "$ind" -ne "0" ] && f="${f}.${ind}"

    if [ -n "$prev_file" ] && [ -f "$f" ]; then
      mv "$f" "$prev_file"
    fi

    prev_file="$f"
    ind=$((ind-1))
  done
}

# 10485760
func_logs_maintain "${HOME}/logs/xeoma-last-video.log" 10485760

# ---------------------------------

SOURCE=/mnt/xeoma-archive
TARGET=/mnt/memfs/xeoma-video-last

mkdir -p "$TARGET" || exit
rm -rf "$TARGET"/* || exit

cd "$SOURCE" || exit

pipe() {
  while read -r file; do
    echo ">>>>>>>> file=${file}"

    mkdir -p "$(dirname "${TARGET}/${file}")" || continue
    ln -s "${SOURCE}/${file}" "${TARGET}/${file}" || continue
  done
}

# за последние 3 часа
find "./" -type f -mmin -180 | pipe

# TODO проверить - есть ли новые файлы с момента последней синхронизации

# echo "[$(date)] sending to office"
# # --progress
# rsync --progress --times --recursive --size-only --delete --delete-excluded --copy-links \
#     "$TARGET"/* office:~/_backup_xeoma_reut_last_video


echo "[$(date)] sending to msk1"
# --progress
rsync --progress --times --recursive --size-only --delete --delete-excluded --copy-links \
    "$TARGET"/* msk1:~/_xeoma_reut_last_video

