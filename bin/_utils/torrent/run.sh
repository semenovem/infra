#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

CONFIG_DIR="${ROOT}/config"
CONFIG_FILE="${ROOT}/config.env"
TORRENTS_DIR="${ROOT}/torrents"
DOWNLOADS_DIR="/Volumes/dat/torrents"

if [ ! -f "$CONFIG_FILE" ]; then
  {
    echo "# В этом файле можно переопределить значения переменных"
    echo
    echo "DOWNLOADS_DIR=${DOWNLOADS_DIR}"
  } >"$CONFIG_FILE"
fi

set -o allexport
# shellcheck disable=SC1090
. "$CONFIG_FILE" || exit 1
set +o allexport

[ ! -d "$DOWNLOADS_DIR" ] \
  && echo "download directory does not exist: '${DOWNLOADS_DIR}'" \
  && exit 1


docker run -d --rm \
    --name torrent \
    --user "${UID}:${GID}" \
    -p 8080:8080 -p 6881:6881/tcp -p 6881:6881/udp \
    -v "${CONFIG_DIR}:/config" \
    -v "${TORRENTS_DIR}:/torrents" \
    -v "${DOWNLOADS_DIR}:/downloads" \
    --add-host "bt.t-ru.org:185.15.211.203" \
    --add-host "bt2.t-ru.org:185.15.211.203" \
    --add-host "bt3.t-ru.org:185.15.211.203" \
    --add-host "bt4.t-ru.org:185.15.211.203" \
    wernight/qbittorrent:4.2
