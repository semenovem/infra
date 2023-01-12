#!/bin/sh

# https://yandex.ru/support/disk-desktop-linux/

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

IMAGE="envi/ya-disk:0.0"
CONTAINER_NAME="ya-disk"
DISK_DIR="/mnt/raid4t_hard/ya-disk"
YA_CONFIG_DIR="${HOME}/.config/yandex-disk"
CMD=$(__core_get_virtualization_app__) || exit 1

# Сборка образа
__core_has_docker_image__ "$IMAGE"
case $? in
0) ;;
1)
  [ -n "$__DRY__" ] && __info__ "Building image [$IMAGE]" && exit 0
  $CMD build --platform=linux/amd64 \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -f "${ROOT}/ya.dockerfile" \
    -t "$IMAGE" \
    "$ROOT" || exit 1
  ;;
*) exit 1 ;;
esac

if [ ! -d "$YA_CONFIG_DIR" ]; then
  mkdir -p "$YA_CONFIG_DIR" || exit 1
fi

help() {
  __info__ "Use arguments: [status|stop|start]"
}

# shellcheck disable=SC2120
is_running() {
  HAS=$(docker ps --filter=name="$CONTAINER_NAME" -q $@)
  [ -n "$HAS" ]
}

OPER=

# Разбор параметров
for p in "$@"; do
  case $p in
  "status") OPER="status" ;;
  "stop") OPER="stop" ;;
  "start") OPER="start" ;;
  *"help" | *"h")
    help
    exit 0
    ;;
  esac
done

# Действие
case $OPER in
"status")
  if is_running; then
    docker exec -it ya-disk yandex-disk status
  else
    __info__ "Container ${CONTAINER_NAME} is not running"
  fi
  ;;

"stop")
  __confirm__ "Stop container ${CONTAINER_NAME} ?" || exit 0

  if is_running; then
    docker exec -it ya-disk yandex-disk stop
    sleep 1
    docker stop "$CONTAINER_NAME" || exit 1
    sleep 1
  fi

  if is_running -a; then
    docker rm "$CONTAINER_NAME" || exit 1
  fi
  ;;

"start")
  if is_running; then
    __info__ "Container [${CONTAINER_NAME}] is already running"
    exit 0
  fi

  __confirm__ "Run a container ${CONTAINER_NAME} ?" || exit 0

  if is_running -a; then
    docker rm "$CONTAINER_NAME" || exit 1
  fi

  docker run --detach --restart unless-stopped --platform=linux/amd64 \
    --name "$CONTAINER_NAME" \
    -w /ya \
    -u "$(id -u):$(id -g)" \
    --memory=500m \
    --memory-swap=500m \
    --memory-reservation=250m \
    --cpus=0.3 \
    -v "${DISK_DIR}:/ya/disk:rw" \
    -v "${ROOT}/config.cfg:/home/app/.config/yandex-disk/config.cfg:rw" \
    -v "${YA_CONFIG_DIR}:/home/app/.config/yandex-disk:rw" \
    "$IMAGE" yandex-disk start \
    --no-daemon \
    --dir=/ya/disk \
    --config=/home/app/.config/yandex-disk/config.cfg \
    --exclude-dirs=__only_cloud,__only_cloud2

  #    yandex-disk start --no-daemon \
  #    --dir=/ya/disk \
  #    --exclude-dirs=__only_cloud,__only_cloud2 \
  #    --config=/home/app/.config/yandex-disk/config.cfg

  #  yandex-disk start --no-daemon --dir=/ya/disk --exclude-dirs=__only_cloud --config=/home/app/.config/yandex-disk/config.cfg
  ;;

*)
  __warn__ "Command not passed"
  help
  ;;

esac
