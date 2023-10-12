#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

# Старт медиа плеера
DOCKER_IMAGE="infra/minidlna:1.0"
CONTAINER_NAME="minidlna"
DOCKER_FILE="${ROOT}/minidlna.dockerfile"
CONFIG_MEDIA="${HOME}/.infra/minidlna/media.conf"

case "$1" in
"start")
  __core_build_docker_image_if_not__ "$DOCKER_IMAGE" "$DOCKER_FILE" "$ROOT" || exit 1

  # проверить и создать локальный конфиг

  TMP_CONFIG_FILE=$(mktemp) || exit 1
  grep -Ev '^[#[:space:]]+|^$' "${ROOT}/minidlna.conf" >"$TMP_CONFIG_FILE" || exit 1

  VOLUMES_ARGS=

  for DIR in $(grep -Ev '^[#[:space:]]+|^$' "$CONFIG_MEDIA"); do
    MOUNT_POINT="/minidlna/media/$(basename "$DIR")"
    echo "media_dir=${MOUNT_POINT}" >> "$TMP_CONFIG_FILE"

    VOLUMES_ARGS="${VOLUMES_ARGS} -v ${DIR}:${MOUNT_POINT}:ro"
  done

#  cat "$TMP_CONFIG_FILE"

#  echo $VOLUMES_ARGS

  # set - -- -v "/mnt/hdd-2t/torrent:/media:ro"
  # set -- $ARGS
  # ls "$@"

  #echo "?????????? $@"
  ##

#    -v "/mnt/hdd-2t/torrent:/media:ro" \
#  exit

  docker run -it --rm --name "$CONTAINER_NAME" \
    -u "nobody:nobody" \
    -v "${ROOT}/minidlna.conf:/minidlna/minidlna.conf:ro" \
    --network host \
    $VOLUMES_ARGS \
    "$DOCKER_IMAGE" minidlnad -f "/minidlna/minidlna.conf" -P "/tmp/minidlna.pid" -R -r && tail -f /dev/null
  #    -v "/home/evg/media:/media:ro" \

  #    $@ \
  #  minidlnad -f "/minidlna/minidlna.conf" -P "/tmp/minidlna.pid" -R -r

#   tail -f /dev/null
  ;;

"stop")
  docker stop "$CONTAINER_NAME"
  ;;

*) __info__ "use minidlna.sh [start | stop | log]" ;;
esac

exit 0
