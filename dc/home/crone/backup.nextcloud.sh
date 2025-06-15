#!/bin/sh

# sudo grep --color -i cron /var/log/syslog

# crontab
# 1 23 * * * sh /home/evg/_infra/dc/home/crone/backup.nextcloud.sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
PROC_FILE="/home/evg/proc/backup.nextcloud.pid"
DAY=$(date +%m%d%H%M)
LOG_DIR="/home/evg/logs/crone.nextcloud"
BACKUP_DIR="/mnt/backup_vol/backups/nextcloud" # on a remote server
EXCLUDE_FILE="$(mktemp)" || exit

if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR" || exit
fi

if [ ! -d "/home/evg/proc" ]; then
  mkdir -p /home/evg/proc
fi

if [ -f "$PROC_FILE" ]; then
  PID="$(cat $PROC_FILE)" || exit

  if [ -d "/proc/${PID}" ]; then
    echo "[INFO][$(date +%m%d%H%m)] another instance is running PID=${PID}"
    exit 0
  fi
fi

# -----------------------------

echo $$ > $PROC_FILE || exit
echo "[INFO]pid=$$ file=${PROC_FILE}"

USER_NAME="" # full before call func
func_sync() {
  LOG_FILE="${LOG_DIR}/${USER_NAME}.${DAY}.log"
  DST_DIR="${BACKUP_DIR}/${USER_NAME}/"
  DST_INCR="${BACKUP_DIR}/${USER_NAME}-incr/${DAY}"

  {
    echo "[INFO] >>> LOG_FILE=$LOG_FILE"
    echo "[INFO] >>> SRC_DIR=$SRC_DIR"
    echo "[INFO] >>> DST_DIR=$DST_DIR"
    echo "[INFO] >>> DST_INCR=$DST_INCR"
  } >> "$LOG_FILE"

  # --dry-run \
  sudo rsync -a --delete --log-file="$LOG_FILE" \
    --bwlimit=10000 \
    --inplace --backup --quiet \
    --rsync-path="mkdir -p ${DST_DIR} && rsync" \
    --exclude '.git' \
    --exclude '.idea' \
    --exclude '*DS_Store' \
    --exclude 'node_modules' \
    --exclude '*.drawio.bkp' \
    --exclude-from "$EXCLUDE_FILE" \
    --backup-dir="$DST_INCR" \
    -e "ssh -p 4022 -i /home/evg/.ssh/id_ecdsa" \
    "$SRC_DIR" "evg@localhost:${DST_DIR}"

  exit_code="$?"

  sh "${ROOT}/../../../call-script.sh" "scr-bot-evgio" "[INFO][nextcloud-backup] for user_name=${USER_NAME}, rsync_code=${exit_code}, moment=${DAY}"
}

USER_NAME="evg"
# to get the contents of a directory use the trailing slash
SRC_DIR="/mnt/soft/nextcloud/app/data/evg/files/"
echo 'media/' > "$EXCLUDE_FILE"
func_sync


USER_NAME="len"
SRC_DIR="/mnt/soft/nextcloud/app/data/len/files/"
: > "$EXCLUDE_FILE"
func_sync

rm "$PROC_FILE"
