#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

set -o allexport
. "${ROOT}/immich/.env"
set +o allexport

DO_RESTORE=
DB_DUMP_FILE="/mnt/vol1/immich/immich.tar.gz"

export COMPOSE_MENU=disable


# Restore Backup
if [ -n "$DO_RESTORE" ]; then     
    docker compose -p "447" --project-directory "${ROOT}/immich" \
        -f "${ROOT}/immich/service-immich.yaml" \
        --parallel=3 create

    docker start immich_postgres
    sleep 10

    gunzip --stdout "$DB_DUMP_FILE" \
    | sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
    | docker exec -i immich_postgres psql --dbname="$DB_DATABASE_NAME" --username="$DB_USERNAME"  
fi

export UID="$(id -u)"
export GID="$(id -g)"


docker compose -p "447" --project-directory "${ROOT}/immich" \
    -f "${ROOT}/immich/service-immich.yaml" \
    --parallel=3 up --quiet-pull --detach


docker compose -p core --project-directory "$ROOT" \
    -f "${ROOT}/service-core.yaml" \
    --parallel=3 up --quiet-pull --detach
    