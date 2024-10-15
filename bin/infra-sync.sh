#!/bin/sh


. "${__INFRA_BIN__}/_lib/core.sh" || exit 1

CFG_DIR="${__CORE_LOCAL_DIR__}/backup"
SYNC_CONF_FILE="${CFG_DIR}/sync.conf"
LAST_SYNC_BASE="${CFG_DIR}/_last-sync" # базовая часть имени файла-синхронизации
LAST_SYNC_FILE=

if [ ! -d "$CFG_DIR" ]; then mkdir -p "$CFG_DIR" || exit 1; fi
if [ ! -f "$SYNC_CONF_FILE" ]; then
  {
    echo "# file of config for sync"
    echo
    echo "# table of sync tacks"
    echo "# REMOTE_HOST | PERIOD_HOUR | LOCAL_PATH      | REMOTE_PATH"
    echo "-----------------------------------------------------------------------"
    echo "office        |      1      | /Vol/data/proj  | /mnt/md1/backup/laptop16work"
    echo "office        |      5      | /Vol/data/_dev  | /mnt/md1/backup/laptop16work"
    echo "home          |     24      | /Vol/data/test  | /mnt/soft/backup001/laptop16work"
    echo
  } > "$SYNC_CONF_FILE"
fi

REMOTE_HOST=
PERIOD_HOUR=
LOCAL_PATH=
REMOTE_PATH=
SERIAL=0

# парсинг файла
while IFS= read -r line_raw; do
  line=$(echo "$line_raw" | xargs)

  [ -z "$line" ] && continue
  echo "$line" | grep -Eq '^\s*[#;-]' && continue

  line=$(echo "$line" | sed -r 's/[|]+//g')

  REMOTE_HOST=$(echo "$line" | awk '{print $1}')
  PERIOD_HOUR=$(echo "$line" | awk '{print $2}')
  LOCAL_PATH=$(echo "$line" | awk '{print $3}')
  REMOTE_PATH=$(echo "$line" | awk '{print $4}')

  if [ -z "$REMOTE_HOST" ] || [ -z "$PERIOD_HOUR" ] || [ -z "$LOCAL_PATH" ] || [ -z "$REMOTE_PATH" ]; then
    echo "[ERRO] invalid line [${line_raw}]"
    continue
  fi

  SERIAL=$((SERIAL+1))

  LAST_SYNC_UNIX_TIME=
  if [ -f "${LAST_SYNC_BASE}-${SERIAL}" ]; then
    LAST_SYNC_UNIX_TIME="$(cat "${LAST_SYNC_BASE}-${SERIAL}")"
  fi

  DIFF="$(($(date +%s) - LAST_SYNC_UNIX_TIME))"
  if [ "$DIFF" -gt "$((PERIOD_HOUR * 3600))" ]; then
    # проверить доступность сервера
    ssh -qn "$REMOTE_HOST" > /dev/null
    [ "$?" -ne 0 ] && echo "[ERRO] remote host unavailable [${REMOTE_HOST}]" && continue

    LAST_SYNC_FILE="${LAST_SYNC_BASE}-${SERIAL}"
    break
  fi

#  echo "SERIAL=${SERIAL}  REMOTE_HOST=${REMOTE_HOST}   PERIOD_HOUR=${PERIOD_HOUR}  LOCAL_PATH=${LOCAL_PATH}  REMOTE_PATH=${REMOTE_PATH}"
#  echo "SERIAL=${SERIAL}  REMOTE_HOST=${REMOTE_HOST}  PERIOD_SEC=$((PERIOD_HOUR * 3600))  DIFF=${DIFF}  LOCAL_PATH=${LOCAL_PATH}   LAST_TIME=${LAST_TIME}  UNIX_SEC=${UNIX_SEC} IS_NEED_UPDATE=${IS_NEED_UPDATE}"

#  echo "Text read from file: $line"
done < "$SYNC_CONF_FILE"

# -------------------
[ -z "$LAST_SYNC_FILE" ] && echo "[INFO] nothing to update" && exit 0


echo "[INFO] REMOTE_HOST=${REMOTE_HOST}"
echo "[INFO] PERIOD_HOUR=${PERIOD_HOUR}"
echo "[INFO] LOCAL_PATH =${LOCAL_PATH}"
echo "[INFO] REMOTE_PATH=${REMOTE_PATH}"
echo "[INFO] SERIAL     =${SERIAL}"
echo "[INFO] LAST_SYNC_FILE     =${LAST_SYNC_FILE}"

__confirm__ "run sync ?" || exit 0

# TODO добавить очистку файла лога перед синком, если лог превышает > 1mb

MONTH=$(date +%m)
DAY_HOUR_MIN=$(date +%d%H%M)
INCREMENT_DIR="${REMOTE_PATH}/$(basename "$LOCAL_PATH")-incr/${MONTH}/${DAY_HOUR_MIN}"

echo "[INFO] $(date) incremental backup (rsync) start with dir [${INCREMENT_DIR}]"

rsync -a --delete --log-file=/dev/stdout --progress --inplace --backup --quiet \
  --rsync-path="mkdir -p ${REMOTE_PATH} && rsync" \
  --exclude '.git' \
  --exclude '.idea' \
  --exclude '.DS_Store' \
  --backup-dir="$INCREMENT_DIR" "$LOCAL_PATH" "${REMOTE_HOST}:${REMOTE_PATH}"


date +%s > "$LAST_SYNC_FILE"
