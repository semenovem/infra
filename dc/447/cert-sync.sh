#!/bin/bash

set -o errexit

[ "$UID" -eq 0 ] && echo "[ERRO][..] user must not be root" && exit 1

[ -z "$__INFRA_LOCAL__" ] && echo "[ERRO][..] empty variable __INFRA_LOCAL__" && exit 1
[ ! -d "$__INFRA_LOCAL__" ] && echo "[ERRO][..] not found dir in variable __INFRA_LOCAL__ [${__INFRA_LOCAL__}] " && exit 1

if hostname | grep -Eqv "mini447|mini47"; then
    echo "[ERRO][..] hostname = $(hostname) is forbidden"
    exit 1
fi

SERTBOT_DIR="${__INFRA_LOCAL__}/certbot"
mkdir -p "$SERTBOT_DIR"

LAST_DIR="${SERTBOT_DIR}/last"
rm -rf "$LAST_DIR"
mkdir "$LAST_DIR"

ssh home "sudo tar czf - -C /home/evg/_infra/.local/certbot/conf ./" | tar xzf - -C "$LAST_DIR"
chmod -R 0700 "${LAST_DIR}"

TARGET_DIR="${SERTBOT_DIR}/conf"

if [ -d "$TARGET_DIR" ]; then 
    FILE_A="${__INFRA_LOCAL__}/certbot/prev-$(date +%d).tar.gz"
    tar -zcf "$FILE_A" -C "$TARGET_DIR" .
    chmod 0600 "$FILE_A"
else 
    mkdir -p "${TARGET_DIR}"
fi

rsync -aPq --delete "${LAST_DIR}/" "$TARGET_DIR"

chmod -R 0740 "${TARGET_DIR}/"*
sudo chown -R evg:root "${TARGET_DIR}/"*

rm -rf "$LAST_DIR"

# docker exec -it core-nginx nginx -s reload
