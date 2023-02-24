#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

CONFIG_DIR="${ROOT}/config"
CONFIG_FILE="${ROOT}/config.env"
TORRENT_FILES_DIR="${ROOT}/torrent-files"
DOWNLOADS_DIR=

if [ ! -f "$CONFIG_FILE" ]; then
  {
    echo "# В этом файле можно переопределить значения переменных"
    echo
    echo "__DOWNLOADS_DIR__="
    echo "__TORRENT_FILES_DIR__="
  } >"$CONFIG_FILE"
fi

set -o allexport
# shellcheck disable=SC1090
. "$CONFIG_FILE" || exit 1
set +o allexport

[ -n "$__DOWNLOADS_DIR__" ] && DOWNLOADS_DIR="$__DOWNLOADS_DIR__"
[ -n "$__TORRENT_FILES_DIR__" ] && TORRENT_FILES_DIR="$__TORRENT_FILES_DIR__"

[ ! -d "$DOWNLOADS_DIR" ] &&
  echo "Download directory does not exist: '${DOWNLOADS_DIR}'" &&
  exit 1

[ ! -d "$TORRENT_FILES_DIR" ] &&
  echo "Torrent files directory does not exist: '${TORRENT_FILES_DIR}'" &&
  exit 1

docker run -d \
  --restart unless-stopped \
  --name=qbittorrent \
  --user "${UID}:${GID}" \
  -e PUID="$UID" \
  -e PGID="$GID" \
  -e TZ=Etc/UTC \
  -e WEBUI_PORT=8080 \
  -p 8080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v "${CONFIG_DIR}:/config" \
  -v "${DOWNLOADS_DIR}:/downloads" \
  -v "${TORRENT_FILES_DIR}:/torrent-files" \
  lscr.io/linuxserver/qbittorrent:4.5.1

#  --add-host "bt.t-ru.org:185.15.211.203" \
#  --add-host "bt2.t-ru.org:185.15.211.203" \
#  --add-host "bt3.t-ru.org:185.15.211.203" \
#  --add-host "bt4.t-ru.org:185.15.211.203" \
