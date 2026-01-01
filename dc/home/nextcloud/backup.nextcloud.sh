#!/bin/bash

# sudo grep --color -i cron /var/log/syslog

# crontab -e
# CRONE_EXEC=y
# 30 0 * * * /bin/bash '/home/evg/_infra/dc/home/nextcloud/backup.nextcloud.sh'

set -o errexit

PROC_FILE="/home/evg/proc/backup.nextcloud.pid"
DAY=$(date +%m%d%H%M)
LOG_DIR="/home/evg/logs/crone.nextcloud"
BACKUP_DIR="/mnt/backup_vol/nextcloud_backups" # on a remote server
FILES_BKP_DIR="${BACKUP_DIR}/user-files"

msg_prefix() {
  echo "[home][nextcloud-bkp][$(date +%m%d_%H:%M:%S)]"
}

notify() {
  bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[INFO]$(msg_prefix) ${1}"
}

failure() {
  bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[ERRO]$(msg_prefix) ${1}"
}

[ "$CRONE_EXEC" = y ] && exec >> "${LOG_DIR}/crone-sync.log" 2>&1

echo "[INFO]$(msg_prefix) start backup nextcloud"
notify 'backup nextcloud'

# -------------------- Preparing
[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"
[ ! -d '/home/evg/proc' ] && mkdir -p '/home/evg/proc'

if [ -f "$PROC_FILE" ]; then
  PID="$(cat $PROC_FILE)"
  [ -d "/proc/${PID}" ] && echo "[INFO]$(msg_prefix) another instance is running PID=${PID}" && exit 0
fi
echo $$ > $PROC_FILE
echo "[INFO]$(msg_prefix) pid=$$ file=${PROC_FILE}"


# -------------------- Check connect to remote server
if ! ERR_MSG="$(ssh -p 4022 evg@localhost ':' 2>&1)"; then
  ERR_MSG="$(echo "$ERR_MSG" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  echo "[ERRO]$(msg_prefix) check connect [${ERR_MSG}]"

  failure "check conn to remote: ${ERR_MSG}"
  exit 1
fi


# -------------------- Check if the database container is running
CONTAINER_ID="$(docker ps --filter name=nextcloud-db -q)"
[ -z "$CONTAINER_ID" ] && notify 'container nextcloud-db not running' && exit 0


# -------------------- Backup database
echo "[INFO]$(msg_prefix) backup database"

docker exec -it -e "PGPASSWORD=nextcloud" nextcloud-db pg_dump -U nextcloud nextcloud \
  | gzip --stdout \
  | ssh -p 4022 evg@localhost "cat > '${BACKUP_DIR}/db/dump-$(date +"%d").sql.gz'"


# -------------------- Backup user files
echo "[INFO]$(msg_prefix) backup user files"


EXCLUDE_FILE="$(mktemp)"

# $1 - user name
# $2 - source path
func_sync() {
  local exit_code=0 user_name="$1" src_dir="$2" cmd dst_dir dst_incr
  cmd="/home/evg/_infra/bin/common/count-objects"

  dst_dir="${FILES_BKP_DIR}/${user_name}/"
  dst_incr="${FILES_BKP_DIR}/${user_name}-incr/${DAY}"


  echo "[INFO]$(msg_prefix)[${user_name}] src_dir=${src_dir}, DST_DIR=${dst_dir}, dst_incr=${dst_incr}"
  echo "[INFO]$(msg_prefix)[${user_name}] source: $(sudo "$cmd" "$src_dir")"
  echo "[INFO]$(msg_prefix)[${user_name}] before: $(ssh -p 4022 evg@localhost "./_infra/bin/common/count-objects '${dst_dir}'")"

  # --dry-run \
  sudo rsync --quiet -a --delete \
    --bwlimit=10000 \
    --inplace --backup --quiet \
    --rsync-path="mkdir -p ${dst_dir} && rsync" \
    --exclude '.git' \
    --exclude '.idea' \
    --exclude '*DS_Store' \
    --exclude 'node_modules' \
    --exclude '*.drawio.bkp' \
    --exclude-from "$EXCLUDE_FILE" \
    --backup-dir="$dst_incr" \
    -e "ssh -p 4022 -i /home/evg/.ssh/id_ecdsa" \
    "$src_dir" "evg@localhost:${dst_dir}" || exit_code="$?"

  if [ "$exit_code" -ne 0 ]; then
    echo "[ERRO]$(msg_prefix)[${user_name}] rsync"
    failure "for user_name=${user_name}, rsync_code=${exit_code}, moment=${DAY}"
    return
  fi

  echo "[INFO]$(msg_prefix)[${user_name}] after : $(ssh -p 4022 evg@localhost "./_infra/bin/common/count-objects '${dst_dir}'")"
}

# to get the contents of a directory use the trailing slash
echo 'media/' > "$EXCLUDE_FILE"
echo 'edu/GolangProfessional/' >> "$EXCLUDE_FILE"
func_sync 'evg' '/mnt/soft/nextcloud/app/data/evg/files/'


: > "$EXCLUDE_FILE"
func_sync 'len' '/mnt/soft/nextcloud/app/data/len/files/'


rm "$PROC_FILE"
