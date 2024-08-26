#!/bin/sh


. "${__INFRA_BIN__}/_lib/core.sh" || exit 1

CFG_DIR="${__CORE_LOCAL_DIR__}/backup"
CFG_FILE="${CFG_DIR}/sync.conf"

if [ ! -d "$CFG_DIR" ]; then mkdir -p "$CFG_DIR" || exit 1; fi
if [ ! -f "$CFG_FILE" ]; then
  {
    echo "# file of config for sync"
    echo "# example: laptop16work"
    echo "__SRC_NAME__=laptop16work"
    echo
    echo "# example: '/Volumes/dat/_proj /Volumes/dat/_dev'"
    echo "__SYNC_FOR_OFFICE__=''"
    echo "__SYNC_FOR_HOME__=''"
    echo
  } > "$CFG_FILE"
fi

. "${CFG_FILE}" || exit 1
MONTH_DAY=$(date +%m%d)

echo "[info] __SRC_NAME__          = ${__SRC_NAME__}"
echo "[info] __BACKUP_FOR_OFFICE__ = ${__BACKUP_FOR_OFFICE__}"
echo "[info] __BACKUP_FOR_HOME__   = ${__BACKUP_FOR_HOME__}"

__confirm__ "run sync ?" || exit 0

# TODO добавить очистку файла лога перед синком, если лог превышает > 1mb


MONTH=$(date +%m)
DAY_HOUR_MIN=$(date +%d%H%M)

SRC_DIR="/Volumes/dat/dion"
LOG_FILE="${HOME}/_infra_log/rsync-dion.log"
mkdir -p "${HOME}/_infra_log"


REMOTE_HOST="office-local"
REMOTE_HOST="evg@office.glazkoff.ru"
REMOTE_HOST="office"
DST_DIR="/mnt/md1/backup/laptop16work"
INCREMENT_DIR="${DST_DIR}/$(basename "$SRC_DIR")-incr/${MONTH}/${DAY_HOUR_MIN}"

# TODO проверить доступность сервера
#

echo "$(date) incremental backup (rsync) start with dir [${INCREMENT_DIR}]" >>"$LOG_FILE"
#if [ -d "$INCREMENT_DIR" ]; then
#  {
#    echo "$(date) incremental dir [${INCREMENT_DIR}] already exist"
#  } >>"$LOG_FILE"
#fi

# --progress
rsync -a --delete --log-file "$LOG_FILE" --inplace --backup --quiet \
  --rsync-path="mkdir -p ${DST_DIR} && rsync" \
  --exclude '.git' \
  --exclude '.idea' \
  --exclude '.DS_Store' \
  --backup-dir="$INCREMENT_DIR" "$SRC_DIR" "${REMOTE_HOST}:${DST_DIR}"
