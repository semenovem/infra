#!/bin/sh

# Старт медиа плеера

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

DOCKER_IMAGE="infra/minidlna:1.0"
CONTAINER_NAME="minidlna"
DOCKER_FILE="${ROOT}/minidlna.dockerfile"
CONFIG_MEDIA="${HOME}/.infra/minidlna/media.conf"

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
  HAS=$(docker ps -a -q --filter "name=${CONTAINER_NAME}") || return 1
  if [ -n "$HAS" ]; then
    docker rm -v "$CONTAINER_NAME" >/dev/null || return 1
  fi
}

stop_container() {
  HAS=$(docker ps -q --filter "name=${CONTAINER_NAME}") || return 1
  if [ -n "$HAS" ]; then
    docker stop "$CONTAINER_NAME" -t 5 >/dev/null || return 1
    HAS=$(docker ps -a -q --filter "name=${CONTAINER_NAME}") || return 1
    docker rm -v "$CONTAINER_NAME" >/dev/null || return 1
  fi
}

case "$1" in
"start")
  __core_build_docker_image_if_not__ "$DOCKER_IMAGE" "$DOCKER_FILE" "$ROOT" || exit 1

  # проверить и создать локальный конфиг
  if [ ! -f "$CONFIG_MEDIA" ]; then
    {
      echo "# Media directories"
      echo "# /mnt/music"
      echo "# /mnt/cinema"
    } >"$CONFIG_MEDIA" || exit 1
  fi

  HAS=$(docker ps -q --filter "name=${CONTAINER_NAME}") || exit 1
  [ -n "$HAS" ] && __info__ "already running" && exit 0
  remove_container || exit 1

  TMP_CONFIG_FILE=$(mktemp) || exit 1
  grep -Ev '^[#[:space:]]+|^$' "${ROOT}/minidlna.conf" >"$TMP_CONFIG_FILE" || exit 1

  VOLUMES_ARGS=

  for DIR in $(grep -Ev '^[#[:space:]]+|^$' "$CONFIG_MEDIA"); do
    MOUNT_POINT="/minidlna/media/$(basename "$DIR")"
    echo "media_dir=${MOUNT_POINT}" >>"$TMP_CONFIG_FILE"
    VOLUMES_ARGS="${VOLUMES_ARGS} -v ${DIR}:${MOUNT_POINT}:ro"
  done

  [ -z "$VOLUMES_ARGS" ] && echo "configuration file ${CONFIG_MEDIA} not contain media directories " && exit

  docker run -d --restart on-failure:10 \
    --name "$CONTAINER_NAME" \
    --memory=100m \
    --memory-swap=0m \
    --cpus 0.5 \
    -u "nobody:nobody" \
    --network host \
    -v "${ROOT}/minidlna.conf:/minidlna/minidlna.conf:ro" \
    $VOLUMES_ARGS \
    "$DOCKER_IMAGE" \
    sh -c 'minidlnad -f "/minidlna/minidlna.conf" -P "/tmp/minidlna.pid" -R -r && tail -f /dev/null'

  docker ps
  ;;

"stop")
  stop_container
  ;;

"status")
  status_container
  ;;

*) help ;;
esac
