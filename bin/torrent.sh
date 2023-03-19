#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

case $1 in
"stop")
  sh "${ROOT}/utils/torrent/stop.sh"
  exit $?
  ;;
"run")
  sh "${ROOT}/utils/torrent/run.sh" $@ || exit 1
  docker logs -f qbittorrent
  exit $?
  ;;

*)
  echo "use torrent.sh [run | stop]"
  ;;

esac
