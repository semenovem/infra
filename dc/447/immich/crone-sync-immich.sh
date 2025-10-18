#!/bin/bash

# создаем дамп БД
# копируем данные
# rsync -avzP --delete evg@192.168.22.200:/mnt/backup_vol/backups/immich/immich_data/ /mnt/vol1/immich/immich_data/

set -o errexit
set -o nounset

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

set -o allexport
. "${ROOT}/.env"
set +o allexport

SYNC_COPY_DIR="/mnt/vol1/immich/synchronized-copy"
if [ ! -d "$SYNC_COPY_DIR" ]; then 
    mkdir -p "$SYNC_COPY_DIR"
fi

# CONTAINER_ID="$(docker ps --filter name=immich_server -q)"
# [ -z "$CONTAINER_ID" ] && echo "[INFO][$(date +%m-%d_%H:%M)]container immich_server not running" && exit 0

# docker exec -t immich_postgres pg_dumpall --clean --if-exists --username="$DB_USERNAME" \
#     | gzip > "${SYNC_COPY_DIR}/dump.sql.gz"

# rsync -avzP --delete /mnt/vol1/immich/immich_data "$SYNC_COPY_DIR"


# -------------------------------


rsync -avzP --delete "$SYNC_COPY_DIR" mini47:/mnt/backup_vol/immich 
