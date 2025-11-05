#!/bin/bash

# crontab
# CRONE_EXEC=y
# 0 0 * * * /bin/bash "/home/evg/_infra/dc/447/immich/sync-immich.sh"
# sudo journalctl -u cron.service

set -o errexit

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

msg_prefix() {
    echo "[mini477][sync-immich][$(date +%m-%d_%H:%M)]"
}

[ "$CRONE_EXEC" = y ] && exec >> '/mnt/vol1/immich/logs/crone-sync.log' 2>&1

echo "[INFO]$(msg_prefix) start sync immich"
bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[INFO]$(msg_prefix) sync immich"

set -o allexport
. "${ROOT}/.env"
set +o allexport

fn_report_failure() {
    echo "[ERRO]$(msg_prefix) $*"
    bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[ERRO]$(msg_prefix) $*"
}

fn_report_info() {
    echo "[INFO]$(msg_prefix) $*"
}

SYNC_COPY_DIR='/mnt/vol1/immich/synchronized-copy'
if [ ! -d "$SYNC_COPY_DIR" ]; then
    fn_report_info "not exists [${SYNC_COPY_DIR}] - creating"
    mkdir -p "$SYNC_COPY_DIR"
fi

CONTAINER_ID="$(docker ps --filter name=immich_server -q)"
[ -z "$CONTAINER_ID" ] && echo "[INFO]$(msg_prefix) container immich_server not running" && exit 0

# ----------- 447
fn_report_info 'creating a local copy'
docker exec -t immich_postgres pg_dumpall --clean --if-exists --username="$DB_USERNAME" \
    | gzip > "${SYNC_COPY_DIR}/tmp_dump.sql.gz"

mv "${SYNC_COPY_DIR}/tmp_dump.sql.gz" "${SYNC_COPY_DIR}/dump.sql.gz"

rsync -azPq --size-only --delete \
    --exclude 'immich_data/encoded-video' \
    --exclude 'immich_data/thumbs' \
    '/mnt/vol1/immich/immich_data' "$SYNC_COPY_DIR"


# $1 = name of server
# $2 = remote path
fn_sync_to() {
    local n="$1" p="$2"

    fn_report_info "sync to ${n}"

    echo "[INFO]$(msg_prefix) ${n} before: $(ssh "$n" "./_infra/bin/common/count-objects '${p}'")"
    rsync -azPq --size-only --delete "$SYNC_COPY_DIR" 'mini47:/mnt/backup_vol/immich' \
        || fn_report_failure "rsync to ${n}"

    echo "[INFO]$(msg_prefix) ${n} after : $(ssh "$n" "./_infra/bin/common/count-objects '${p}'")"
}

fn_sync_to 'mini47' '/mnt/backup_vol/immich/synchronized-copy'
fn_sync_to 'home' '/mnt/raid4t_soft/immich/synchronized-copy'
