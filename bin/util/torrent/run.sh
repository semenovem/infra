#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

CONFIG_DIR="${ROOT}/config"
CONFIG_FILE="${ROOT}/config.env"
TORRENT_FILES_DIR=
DOWNLOADS_DIR=
INCOMPLETE_DIR=
GUI="$(id -g)"

if [ ! -f "$CONFIG_FILE" ]; then
  __confirm__ "Создать необходимые файлы для старта qbittorrent ?" || exit 0
fi

if [ ! -f "$CONFIG_FILE" ]; then
  {
    echo "# В этом файле нужно указать пути к директориям"
    echo
    echo "# Каталог для загрузки:"
    echo "__DOWNLOADS_DIR__="
    echo "# Каталог для не завершенных загрузок:"
    echo "__INCOMPLETE_DIR__="
    echo "# Каталог для файлов торрентов:"
    echo "__TORRENT_FILES_DIR__="
    echo "# ID группы, с которой нужно создавать загруженные файлы:"
    echo "__GUI__="
  } >"$CONFIG_FILE"
fi

set -o allexport
# shellcheck disable=SC1090
. "$CONFIG_FILE" || exit 1
set +o allexport

[ -n "$__GUI__" ] && GUI="$__GUI__"

[ -n "$__DOWNLOADS_DIR__" ] && DOWNLOADS_DIR="$__DOWNLOADS_DIR__"
[ -n "$__INCOMPLETE_DIR__" ] && INCOMPLETE_DIR="$__INCOMPLETE_DIR__"
[ -n "$__TORRENT_FILES_DIR__" ] && TORRENT_FILES_DIR="$__TORRENT_FILES_DIR__"

if [ -n "$DOWNLOADS_DIR" ]; then
  [ -z "$INCOMPLETE_DIR" ] && INCOMPLETE_DIR="$DOWNLOADS_DIR"
  [ -z "$TORRENT_FILES_DIR" ] && TORRENT_FILES_DIR="$DOWNLOADS_DIR"
fi

if [ ! -d "$DOWNLOADS_DIR" ]; then
  mkdir "$DOWNLOADS_DIR" || exit 1
fi

if [ ! -d "$INCOMPLETE_DIR" ]; then
  mkdir "$INCOMPLETE_DIR"
fi

if [ ! -d "$TORRENT_FILES_DIR" ]; then
  mkdir "$TORRENT_FILES_DIR"
fi

# Проверить запущен ли сервис
# если в контейнер остановлен - удалить и пересоздать

HAS=$(docker ps --filter=name=qbittorrent -q) || exit 1
[ -n "$HAS" ] && __info__ "already running" && exit 0

HAS=$(docker ps --filter=name=qbittorrent -q -a) || exit 1
if [ -n "$HAS" ]; then
  docker rm qbittorrent || exit 1
fi

docker run -d \
  --restart unless-stopped \
  --name=qbittorrent \
  --cpus 0.5 \
  -e PUID="$(id -u)" \
  -e PGID="$(id -g)" \
  -e TZ=Etc/UTC \
  -e WEBUI_PORT=8080 \
  -p 8080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v "${CONFIG_DIR}:/config" \
  -v "${DOWNLOADS_DIR}:/downloads" \
  -v "${INCOMPLETE_DIR}:/incomplete" \
  -v "${TORRENT_FILES_DIR}:/torrent-files" \
  lscr.io/linuxserver/qbittorrent:4.5.5
