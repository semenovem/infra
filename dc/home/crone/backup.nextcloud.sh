#!/bin/sh

# каждый день в 23 часа
# crontab
# 1 23 * * * sh /home/evg/infra/dc/home/crone/backup.folder.sh
# 1 16 30 * * sh /home/evg/infra/dc/home/crone/backup.folder.sh

# sudo grep --color -i cron /var/log/syslog
mkdir -p /home/evg/logs
mkdir -p /home/evg/proc

LOG_DIR="/home/evg/logs"
PREFIX="crone.nextcloud"
PROC_FILE="/home/evg/proc/backup.nextcloud.pid"
DAY=$(date +%m%d)

if [ -f "$PROC_FILE" ]; then
  PID="$(cat $PROC_FILE)" || exit

  if [ -d "/proc/${PID}" ]; then
    echo "[INFO][$(date +%m%d%H%m)] another instance is running PID=${PID}" >> "${LOG_DIR}/${PREFIX}_${DAY}_try"
    exit 0
  fi
fi

echo $$ > $PROC_FILE || exit
echo "[INFO]pid=$$ file=${PROC_FILE}"


# echo "$(date) incremental backup (rsync) start with dir [${INCREMENT_DIR}]" >>"$LOG_FILE"
# if [ -d "$INCREMENT_DIR" ]; then
#   {
#     echo "$(date) incremental dir [${INCREMENT_DIR}] already exist"
#   } >>"$LOG_FILE"
# fi

#if [ -e "$INCREMENT_DIR" ] ; then
#  rm -rf "$INCREMENT_DIR"
#fi


DST_BACKUP_DIR=/mnt/vol_media_1/backup_nextcloud

SRC_EVG="/mnt/soft/nextcloud/app/data/evg/files/"
DST_EVG="${DST_BACKUP_DIR}/evg"
DST_EVG_INCR="${DST_BACKUP_DIR}/evg-incr/${DAY}"

SRC_LEN="/mnt/soft/nextcloud/app/data/len/files/"
DST_LEN="${DST_BACKUP_DIR}/len"
DST_LEN_INCR="${DST_BACKUP_DIR}/len-incr/${DAY}"


rsync -a --delete --log-file="${LOG_DIR}/${PREFIX}_evg.${DAY}.log" \
  --inplace --backup --quiet \
  --rsync-path="mkdir -p ${DST_EVG} && rsync" \
  --exclude '.git' \
  --exclude '.idea' \
  --exclude '.DS_Store' \
  --exclude 'node_modules' \
  --backup-dir="$DST_EVG_INCR" \
  "$SRC_EVG" "$DST_EVG"


exit


rsync -a --delete --log-file="${LOG_DIR}/${PREFIX}_len.${DAY}.log" \
  --inplace --backup --quiet \
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

