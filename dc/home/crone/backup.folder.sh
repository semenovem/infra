#!/bin/sh

# Копия каждый день в 23 часа
# crontab
# 1 23 * * * sh /home/evg/infra/dc/home/crone/backup.folder.sh
# 1 16 30 * * sh /home/evg/infra/dc/home/crone/backup.folder.sh

# sudo grep --color -i cron /var/log/syslog

DAY=$(date +%m%d)
INCREMENT_DIR="/mnt/hard/ya-disk/backups/glazkov/alex-incr/${DAY}"
SRC_DIR="/mnt/hard/ya-disk/ИП Глазков/"
DST_DIR="/mnt/hard/ya-disk/backups/glazkov/alex/"
LOG_FILE="/home/evg/_infra_log/cron-glazkov-alex.log"

echo "$(date) incremental backup (rsync) start with dir [${INCREMENT_DIR}]" >>"$LOG_FILE"
if [ -d "$INCREMENT_DIR" ]; then
  {
    echo "$(date) incremental dir [${INCREMENT_DIR}] already exist"
  } >>"$LOG_FILE"
fi

#if [ -e "$INCREMENT_DIR" ] ; then
#  rm -rf "$INCREMENT_DIR"
#fi

rsync -a --delete --log-file "$LOG_FILE" --quiet --inplace --backup --backup-dir="$INCREMENT_DIR" "$SRC_DIR" "$DST_DIR"


rsync -a --delete --log-file=/dev/stdout --inplace --backup --quiet \
  --rsync-path="mkdir -p ${REMOTE_PATH} && rsync" \
  --exclude '.git' \
  --exclude '.idea' \
  --exclude '.DS_Store' \
  --exclude 'node_modules' \
  --backup-dir="$INCREMENT_DIR" "$LOCAL_PATH" "${REMOTE_HOST}:${REMOTE_PATH}"
