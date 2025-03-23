#!/bin/sh

# Копия каждый день в 23 часа
# crontab
# 1 23 * * * sh /home/evg/infra/dc/home/crone/backup.folder.sh
# 1 16 30 * * sh /home/evg/infra/dc/home/crone/backup.folder.sh

# sudo grep --color -i cron /var/log/syslog

DAY=$(date +%m%d)

# echo "$(date) incremental backup (rsync) start with dir [${INCREMENT_DIR}]" >>"$LOG_FILE"
# if [ -d "$INCREMENT_DIR" ]; then
#   {
#     echo "$(date) incremental dir [${INCREMENT_DIR}] already exist"
#   } >>"$LOG_FILE"
# fi

#if [ -e "$INCREMENT_DIR" ] ; then
#  rm -rf "$INCREMENT_DIR"
#fi

LOG_DIR="/home/evg/logs"

SRC_EVG="/mnt/soft/nextcloud/app/data/evg/files/"
DST_EVG="/mnt/vol_backup_1/backups_nextcloud/evg"
DST_EVG_INCR=/"mnt/vol_backup_1/backups_nextcloud/evg-incr/${DAY}"

SRC_LEN="/mnt/soft/nextcloud/app/data/len/files/"
DST_LEN="/mnt/vol_backup_1/backups_nextcloud/len"
DST_LEN_INCR="/mnt/vol_backup_1/backups_nextcloud/len-incr/${DAY}"


rsync -a --delete --log-file="${LOG_DIR}/len.${DAY}.log" --inplace --backup --quiet \
  --rsync-path="mkdir -p ${DST_LEN} && rsync" \
  --exclude '.git' \
  --exclude '.idea' \
  --exclude '.DS_Store' \
  --exclude 'node_modules' \
  --backup-dir="$DST_LEN_INCR" \
  "$SRC_LEN" "$DST_LEN"



exit

# rsync -a --delete --log-file="${LOG_DIR}/len.${DAY}.log" --inplace --backup --quiet \
#   --rsync-path="mkdir -p ${DST_LEN} && rsync" \
#   --exclude '.git' \
#   --exclude '.idea' \
#   --exclude '.DS_Store' \
#   --exclude 'node_modules' \
#   --backup-dir="$INCREMENT_DIR" \
#   "$SRC_LEN" "$DST_LEN"

