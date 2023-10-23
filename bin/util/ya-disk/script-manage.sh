#!/bin/sh

# https://yandex.ru/support/disk-desktop-linux/

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

IMAGE="infra/ya-disk:0.1"
CONTAINER_NAME="ya-disk"
YA_CONFIG_DIR="${HOME}/.config/yandex-disk"

NUMBER=1
LOCAL_CONFIG_DIR="${__CORE_STATE_DIR__}/ya-disk"
LOCAL_CONFIG_FILE=

# Сборка образа
__core_has_docker_image__ "$IMAGE"
case $? in
0) ;;
1)
  docker build --platform=linux/amd64 \
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
  __info__ "Local config: [${LOCAL_CONFIG_DIR}]"
}

if [ ! -d "$LOCAL_CONFIG_DIR" ]; then
  mkdir "$LOCAL_CONFIG_DIR" || exit 1

  {
    echo "# Example config"
    echo "# Directories to exclude (do not download content)"
    echo "__EXCLUDE__="
    echo "# Authorization data"
    echo "__AUTH__="
    echo "# Data"
    echo "__YA_DISK_DIR__="
  } > "${LOCAL_CONFIG_DIR}/example.conf"

fi

# shellcheck disable=SC2120
is_running() {
  HAS=$(docker ps --filter=name="$CONTAINER_NAME" -q "$@")
  [ -n "$HAS" ]
}

OPER=

# Разбор параметров
for p in "$@"; do
  case $p in
  "status") OPER="status" ;;
  "stop") OPER="stop" ;;
  "start") OPER="start" ;;
  "2") NUMBER="2" ;;
  "help" | "h")
    help
    exit 0
    ;;
  esac
done

CONTAINER_NAME="${CONTAINER_NAME}-${NUMBER}"
LOCAL_CONFIG_FILE="${LOCAL_CONFIG_DIR}/${NUMBER}.conf"

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

  if [ ! -f "$LOCAL_CONFIG_FILE" ]; then
    __warn__ "local config [${LOCAL_CONFIG_FILE}] not exists"
    exit 1
  fi

  # shellcheck disable=SC1090
  . "$LOCAL_CONFIG_FILE" || exit 1

  # создать конфиг - директорию диска __AUTH__

  echo ">>>>>>> $__EXCLUDE__"
  echo ">>>>>>> $__YA_DISK_DIR__"
  echo ">>>>>>> $__AUTH__"
  echo ">>>>>>> $YA_CONFIG_DIR"


  docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -w /ya \
    -u "$(id -u):$(id -g)" \
    --memory=500m \
    --memory-swap=500m \
    --cpus=0.3 \
    -v "${__YA_DISK_DIR__}:/ya/disk:rw" \
    -v "${ROOT}/config.cfg:/home/app/.config/yandex-disk/config.cfg:rw" \
    -v "${__AUTH__}:/home/app/.config/yandex-disk:rw" \
    "$IMAGE"  bash

    exit

    yandex-disk start \
    --no-daemon \
    --dir=/ya/disk \
    --exclude-dirs=__only_cloud,__only_cloud2


  exit

  docker run --detach --restart unless-stopped --platform=linux/amd64 \
    --name "$CONTAINER_NAME" \
    -w /ya \
    -u "$(id -u):$(id -g)" \
    --memory=500m \
    --memory-swap=500m \
    --cpus=0.3 \
    -v "${__YA_DISK_DIR__}:/ya/disk:rw" \
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
  __info__ "Command not passed"
  help
  ;;

esac
