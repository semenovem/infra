#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

# Старт медиа плеера
DOCKER_IMAGE="infra/minidlna:1.0"
CONTAINER_NAME="minidlna"
DOCKER_FILE="${ROOT}/minidlna.dockerfile"
PORT="8200"
CONFIG_MEDIA="${HOME}/.infra/minidlna/media.conf"

case "$1" in
"start")
  __core_build_docker_image_if_not__ "$DOCKER_IMAGE" "$DOCKER_FILE" "$ROOT" || exit 1

#  TMP_CONFIG_FILE=$(mktemp) || exit 1
#  cat "${ROOT}/minidlna.conf" > "$TMP_CONFIG_FILE" || exit 1
  ARGS="-v '/mnt/hdd-2t/torrent:/media:ro'"


  for dir in $(grep -Ev '^[#[:space:]]+|^$' "$CONFIG_MEDIA"); do
    echo ">>>>>>>>>>>> media_dir=/media/$dir"
  done

# set - -- -v "/mnt/hdd-2t/torrent:/media:ro"
 set -- $ARGS
# ls "$@"

#echo "?????????? $@"
##
#  exit

  docker run -it --rm --name "$CONTAINER_NAME" \
    -u "nobody:nobody" \
    -p "${PORT}:8200" \
    -v "${ROOT}/minidlna.conf:/minidlna-dir/minidlna.conf:ro" \
    $@ \
    "$DOCKER_IMAGE" sh

  #  minidlnad -f "/minidlna-dir/minidlna.conf" -P "/tmp/minidlna.pid" -R -r
  ;;

"stop")
  docker stop "$CONTAINER_NAME"
  ;;

*) __info__ "use minidlna.sh [start | stop | log]" ;;
esac

exit 0
