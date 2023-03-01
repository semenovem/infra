#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

CONFIG_DIR="${ROOT}/config"
CONFIG_FILE="${ROOT}/config.env"
TORRENT_FILES_DIR=
DOWNLOADS_DIR=
GUI="$(id -g)"

# TODO подтверждение устаноки при первом старте

if [ ! -f "$CONFIG_FILE" ]; then
  __confirm__ "Создать необходимые файлы для старта qbittorrent ?"
fi

if [ ! -f "$CONFIG_FILE" ]; then
  {
    echo "# В этом файле нужно указать пути к директориям"
    echo
    echo "# Каталог для загрузки:"
    echo "__DOWNLOADS_DIR__="
    echo "# Каталок для файлов торрентов:"
    echo "__TORRENT_FILES_DIR__="
    echo "# ID группы, с котороый нужно создавать загруженные файлы:"
    echo "__GUI__="
  } >"$CONFIG_FILE"
fi

set -o allexport
# shellcheck disable=SC1090
. "$CONFIG_FILE" || exit 1
set +o allexport

[ -n "$__GUI__" ] && GUI="$__GUI__"

[ -n "$__DOWNLOADS_DIR__" ] && DOWNLOADS_DIR="$__DOWNLOADS_DIR__"
[ -n "$__TORRENT_FILES_DIR__" ] && TORRENT_FILES_DIR="$__TORRENT_FILES_DIR__"

[ ! -d "$DOWNLOADS_DIR" ] &&
  echo "Download directory does not exist: '${DOWNLOADS_DIR}'" &&
  exit 1

[ ! -d "$TORRENT_FILES_DIR" ] &&
  echo "Torrent files directory does not exist: '${TORRENT_FILES_DIR}'" &&
  exit 1

# Проверить запущен ли сервис
# если в контейнер остановлен - удалить и пересоздать

HAS=$(docker ps --filter=name=qbittorrent -q) || exit 1
[ -n "$HAS" ] && exit 0

HAS=$(docker ps --filter=name=qbittorrent -q -a) || exit 1
if [ -n "$HAS" ]; then
  docker rm qbittorrent || exit 1
fi

docker run -d \
  --restart unless-stopped \
  --name=qbittorrent \
  -e PUID="$(id -u)" \
  -e PGID="$GUI" \
  -e TZ=Etc/UTC \
  -e WEBUI_PORT=8080 \
  -p 8080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v "${CONFIG_DIR}:/config" \
  -v "${DOWNLOADS_DIR}:/downloads" \
  -v "${TORRENT_FILES_DIR}:/torrent-files" \
  lscr.io/linuxserver/qbittorrent:4.5.1
