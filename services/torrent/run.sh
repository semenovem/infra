#!/bin/bash

CONFIG="${PWD}/config"
TORRENTS="${PWD}/torrents"

DOWNLOADS="${PWD}/downloads"
DOWNLOADS="/Volumes/dat/torrents"

[ ! -d "$DOWNLOADS" ] \
  && echo "download directory does not exist: '${DOWNLOADS}'" \
  && exit 1


docker run -d --rm \
    --name torrent \
    --user "${UID}:${GID}" \
    -p 8080:8080 -p 6881:6881/tcp -p 6881:6881/udp \
    -v "${CONFIG}:/config" \
    -v "${TORRENTS}:/torrents" \
    -v "${DOWNLOADS}:/downloads" \
    --add-host "bt.t-ru.org:185.15.211.203" \
    --add-host "bt2.t-ru.org:185.15.211.203" \
    --add-host "bt3.t-ru.org:185.15.211.203" \
    --add-host "bt4.t-ru.org:185.15.211.203" \
    wernight/qbittorrent:4.2
