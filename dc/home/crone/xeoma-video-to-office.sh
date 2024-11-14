#!/bin/sh

# каждый день в 23 часа
# crontab
# 1 * * * * sh /home/evg/_infra/dc/home/crone/xeoma-video-to-office.sh
LOG_FILE=/home/evg/_infra/dc/home/crone/.xeoma-video-to-office.log
LOG_FILE_1=/home/evg/_infra/dc/home/crone/.xeoma-video-to-office_1.log

# sudo grep --color -i cron /var/log/syslog



if [ -f "$LOG_FILE" ]; then
  SIZE_LOG_FILE="$(stat --printf="%s" "$LOG_FILE")"

  # 10485760
  if [ "$SIZE_LOG_FILE" -gt 1048576 ]; then
    mv "$LOG_FILE" "$LOG_FILE_1"
  fi
fi


SOURCE=/mnt/xeoma-archive
TARGET=/mnt/memfs/xeoma-video-last

echo "[$(date)] start" >> "$LOG_FILE"

mkdir -p "$TARGET" || exit
rm -rf "$TARGET"/* || exit

cd "$SOURCE" || exit

pipe() {
  while read -r file; do
    echo "[$(date)] >>> ${file}" >> "$LOG_FILE"
    mkdir -p "$(dirname "${TARGET}/${file}")" || continue
    ln -s "${SOURCE}/${file}" "${TARGET}/${file}" || continue
  done
}

# find "./" -type f -mmin -100 | pipe
# за последние сутки
find "./" -type f -mmin -1440 | pipe

# TODO проверить - есть ли новые файлы с момента последней синхронизации

# exit

rsync --progress --times --recursive --size-only --delete --delete-excluded --copy-links \
    "$TARGET"/* office:/home/evg/_backup_xeoma_video_home

rsync --progress --times --recursive --size-only --delete --delete-excluded --copy-links \
    "$TARGET"/* /mnt/hdd-2t/ya-disk/media/_current/xeoma-video-last-24-hours

echo "[$(date)] end" >> "$LOG_FILE"
