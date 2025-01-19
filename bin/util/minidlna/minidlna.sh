#!/bin/sh

# Старт медиа плеера

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

DOCKER_IMAGE="infra/minidlna:1.0"
CONTAINER_NAME="minidlna"
DOCKER_FILE="${ROOT}/minidlna.dockerfile"
CONFIG_MEDIA="${__CORE_LOCAL_DIR__}/minidlna/media.conf"

status_container() {
  HAS=$(docker ps -q --filter "name=${CONTAINER_NAME}") || return 1
  [ -n "$HAS" ] && __info__ "status: running" || __info__ "status: not running"
}

help() {
  __info__ "use minidlna.sh [start | stop | status]"
  __info__ "config file: ${CONFIG_MEDIA}"
}


[ -z "$1" ] && status_container && help && exit 0

remove_container() {
  HAS=$(docker ps -a -q --filter "name=${CONTAINER_NAME}") || return
  if [ -n "$HAS" ]; then
    docker rm -v "$CONTAINER_NAME" >/dev/null || return
  fi
}

stop_container() {
  HAS=$(docker ps -q --filter "name=${CONTAINER_NAME}") || return
  if [ -n "$HAS" ]; then
    docker stop "$CONTAINER_NAME" -t 5 >/dev/null || return
    HAS=$(docker ps -a -q --filter "name=${CONTAINER_NAME}") || return
    docker rm -v "$CONTAINER_NAME" >/dev/null || return
  fi
}

case "$1" in
"start")
  __core_build_docker_image_if_not__ "$DOCKER_IMAGE" "$DOCKER_FILE" "$ROOT" || exit

  # проверить и создать локальный конфиг
  if [ ! -f "$CONFIG_MEDIA" ]; then
    {
      echo "# Media directories"
      echo "# /mnt/music  /to-music"
      echo "# /mnt/cinema /to-cinema"
    } >"$CONFIG_MEDIA" || exit 1
  fi

  HAS=$(docker ps -q --filter "name=${CONTAINER_NAME}") || exit
  [ -n "$HAS" ] && __info__ "already running" && exit 0
  remove_container || exit

  # TMP_CONFIG_FILE=$(mktemp) || exit 1
  # grep -Ev '^[#[:space:]]+|^$' "${ROOT}/minidlna.conf" >"$TMP_CONFIG_FILE" || exit 1

  VOLUMES_ARGS=

  filename="$1"
  while read -r line; do
    echo "$line" | grep -Evq '^[#[:space:]]+|^$' || continue
    FROM_DIR=
    TO_DIR=

    for it in $line; do
      [ -z "$FROM_DIR" ] && FROM_DIR="$it" && continue
      TO_DIR="$it"
    done

    [ -z "$TO_DIR" ] && TO_DIR="$(basename "$FROM_DIR")"
    MOUNT_POINT="/minidlna/media/${TO_DIR}"
    MOUNT_POINT="$( echo "$MOUNT_POINT" | tr -s /)"

    VOLUMES_ARGS="${VOLUMES_ARGS} -v ${FROM_DIR}:${MOUNT_POINT}:ro"
  done < "$CONFIG_MEDIA"

  [ -z "$VOLUMES_ARGS" ] && echo "configuration file ${CONFIG_MEDIA} not contain media directories " && exit 1


  # echo ">>>>>>>>>> $VOLUMES_ARGS"

  # exit 0


  docker run -d --restart on-failure:10 \
    --network host \
    --name "$CONTAINER_NAME" \
    --memory=100m \
    --memory-swap=100m \
    --cpus 0.5 \
    -u "nobody:nobody" \
    -v "${ROOT}/minidlna.conf:/minidlna/minidlna.conf:ro" \
    $VOLUMES_ARGS \
    "$DOCKER_IMAGE" \
    sh -c 'minidlnad -f "/minidlna/minidlna.conf" -P "/tmp/minidlna.pid" -R -r && tail -f /dev/null'
  ;;

"stop")
  stop_container
  ;;

"status")
  status_container
  ;;

*) help ;;
esac
