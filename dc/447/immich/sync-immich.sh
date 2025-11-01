#!/bin/bash

# создаем дамп БД
# копируем данные
# /mnt/vol1/immich/logs/crone-sync.log
# sudo journalctl -u cron.service

set -o errexit
set -o nounset

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")


set -o allexport
. "${ROOT}/.env"
set +o allexport

fn_report_failure() {
    echo "[ERRO][sync-immich][$(date +%m-%d_%H:%M)] $*"
    bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[ERRO][mini447][sync-immich] $*"
}

fn_report_info() {
    echo "[INFO][sync-immich][$(date +%m-%d_%H:%M)] $*"
}

SYNC_COPY_DIR="/mnt/vol1/immich/synchronized-copy"
if [ ! -d "$SYNC_COPY_DIR" ]; then 
    fn_report_info "not exists [${SYNC_COPY_DIR}] - creating"
    mkdir -p "$SYNC_COPY_DIR"
fi

CONTAINER_ID="$(docker ps --filter name=immich_server -q)"
[ -z "$CONTAINER_ID" ] && echo "[INFO][$(date +%m-%d_%H:%M)]container immich_server not running" && exit 0

# ----------- 447
fn_report_info "creating a local copy"
docker exec -t immich_postgres pg_dumpall --clean --if-exists --username="$DB_USERNAME" \
    | gzip > "${SYNC_COPY_DIR}/tmp_dump.sql.gz"

mv "${SYNC_COPY_DIR}/tmp_dump.sql.gz" "${SYNC_COPY_DIR}/dump.sql.gz"

rsync -azP --size-only --delete \
    --exclude 'immich_data/encoded-video' \
    --exclude 'immich_data/thumbs' \
    /mnt/vol1/immich/immich_data "$SYNC_COPY_DIR"


# ---------- mini47
fn_report_info "sync to mini47"
rsync -azP --size-only --delete \
    "$SYNC_COPY_DIR" mini47:/mnt/backup_vol/immich \
    || fn_report_failure "rsync to mini47"


# ---------- home
fn_report_info "sync to home"
rsync -azP --size-only --delete \
    "$SYNC_COPY_DIR" home:/mnt/raid4t_soft/immich \
    || fn_report_failure "rsync to home server"

