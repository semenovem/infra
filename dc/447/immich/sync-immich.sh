#!/bin/bash

# crontab
# CRONE_EXEC=y
# 0 0 * * * /bin/bash "/home/evg/_infra/dc/447/immich/sync-immich.sh"
# sudo journalctl -u cron.service

# $1 - server-name

[ "$CRONE_EXEC" = y ] && exec >> '/mnt/vol1/immich/logs/crone-sync2.log' 2>&1
set -o errexit

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
SERVER_NAME="$1"
MONTH_DAY="$(date "+%m%d")"

msg_prefix() {
    local sn
    [ -n "$SERVER_NAME" ] && sn="[server_name=${SERVER_NAME}]"
    echo "[mini477][$(basename "$0")][$(date +%m-%d_%H:%M)]${sn}"
}

err() {
    echo "[ERRO]$(msg_prefix) $*" >&2
}

info() {
    echo "[INFO]$(msg_prefix) $*"
}

fn_report_failure() {
    err "$*"
    bash "/home/evg/_infra/bin/util/bot-evgio.sh" "❌ $(msg_prefix) $*"
}

info "start sync immich"

[ -z "$(docker ps --filter name=immich_server -q)" ] && fn_report_failure "container immich_server not running" && exit 1

# $1 - name of server
# $2 - dir
fn_count() {
    ssh "$1" "~/_infra/bin/common/count-objects --exclude encoded-video --exclude thumbs --only-total '${2}'" || fn_report_failure "ssh count-objects"
}

# $1 = name of server
# $2 = remote path
fn_sync_to() {
    local n="$1" bak_dir="${2}/immich_data" bak_incr_dir="${2}/immich_data_incr/${MONTH_DAY}" result_code=0
    local orig_count remote_before_count remote_after_count msg

    info "bak_dir=${bak_dir} bak_incr_dir=${bak_incr_dir}"
    
    orig_count="$(~/_infra/bin/common/count-objects --exclude encoded-video --exclude thumbs --only-total '/mnt/vol1/immich/immich_data')"
    info "source origin: ${orig_count}"

    remote_before_count="$(fn_count "$n" "${bak_dir}")"
    info "remote before: ${remote_before_count}"

    rsync -azPq --inplace --backup --delete --delete-excluded \
        --backup-dir="$bak_incr_dir" \
        --rsync-path="mkdir -p ${bak_dir} && rsync" \
        --exclude 'encoded-video' \
        --exclude 'thumbs' \
        "/mnt/vol1/immich/immich_data/" "${n}:${bak_dir}" || result_code="$?"
        
    if [ "$result_code" -eq 0 ]; then
        remote_after_count="$(fn_count "$n" "${bak_dir}")"
        info "remote after_: ${remote_after_count}"

        msg="origin ${orig_count} remote before ${remote_before_count} after ${remote_after_count}"
        bash "/home/evg/_infra/bin/util/bot-evgio.sh" "✅$(msg_prefix) sync immich: $(echo "$msg" | tr -s ' ')"
    else 
        fn_report_failure "rsync to ${n}"
    fi

    return "$result_code"
}

case "$SERVER_NAME" in 
    "home") fn_sync_to 'home' '/mnt/raid4t_soft/immich' ;;
    "mini47") fn_sync_to 'mini47' '/mnt/backup_vol/immich' ;;
    *) 
    [ -z "$SERVER_NAME" ] && err "empty server name in \$1" || err "unknown server_name in [\$1]"
    exit 1
     ;;
esac
