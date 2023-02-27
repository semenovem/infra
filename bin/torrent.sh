#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

if [ "$1" = "stop" ]; then
  sh "${ROOT}/utils/torrent/stop.sh"
  exit $?
fi

sh "${ROOT}/utils/torrent/run.sh" $@

docker logs -f qbittorrent
