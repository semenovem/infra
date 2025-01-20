#!/bin/sh

# https://yandex.ru/support/disk-desktop-linux/

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

IMAGE="infra/ya-disk:0.1"
CONTAINER_NAME="ya-disk"

NUMBER=1
CONFIG_DIR="${__CORE_LOCAL_DIR__}/ya-disk"

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

help() {
  __info__ "Use arguments: [status|stop|start]"
  __info__ "Local config dir: [${CONFIG_DIR}]"
}

if [ ! -d "$CONFIG_DIR" ]; then
  mkdir "$CONFIG_DIR" || exit 1

  {
    echo "# Example config"
    echo "# Directories to exclude (do not download content)"
    echo "__EXCLUDE__="
    echo "# Authorization data"
    echo "__AUTH__=${HOME}/.config/yandex-disk"
    echo "# Data"
    echo "__YA_DISK_DIR__="
  } >"${CONFIG_DIR}/example.conf"
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
LOCAL_CONFIG_FILE="${CONFIG_DIR}/config-${NUMBER}.env"

__info__ "LOCAL_CONFIG_FILE = ${LOCAL_CONFIG_FILE}"

# Действие
case $OPER in
"status")
  if is_running; then
    docker exec -it "$CONTAINER_NAME" yandex-disk status --dir=/ya/disk
  else
    __info__ "Container ${CONTAINER_NAME} is not running"
  fi
  ;;

"stop")
  __confirm__ "Stop container ${CONTAINER_NAME} ?" || exit 0

  if is_running; then
    docker exec -it "$CONTAINER_NAME" yandex-disk stop
    sleep 1
    docker stop "$CONTAINER_NAME" || exit 1
    sleep 1
  fi

  if is_running -a; then
    docker rm "$CONTAINER_NAME" || exit 1
  fi
  ;;

"start")
  if [ ! -f "$LOCAL_CONFIG_FILE" ]; then
    __warn__ "local config [${LOCAL_CONFIG_FILE}] not exists"
    exit 1
  fi

  # shellcheck disable=SC1090
  . "$LOCAL_CONFIG_FILE" || exit 1

  __info__ "__EXCLUDE__     = ${__EXCLUDE__}"
  __info__ "__YA_DISK_DIR__ = ${__YA_DISK_DIR__}"
  __info__ "__AUTH__        = ${__AUTH__}"

  if is_running; then
    __info__ "Container [${CONTAINER_NAME}] is already running"
    exit 0
  fi

  __confirm__ "Run a container ${CONTAINER_NAME} ?" || exit 0

  if is_running -a; then
    docker rm "$CONTAINER_NAME" || exit 1
  fi

  # -it --rm
  # --detach --restart unless-stopped
  docker run --detach --restart unless-stopped \
    --name "$CONTAINER_NAME" \
    -u "$(id -u):$(id -g)" \
    -w /ya \
    --memory=500m \
    --memory-swap=500m \
    --cpus=1 \
    -v "/etc/group:/etc/group:ro" \
    -v "/etc/passwd:/etc/passwd:ro" \
    -v "${__YA_DISK_DIR__}:/ya/disk:rw" \
    -v "${__AUTH__}:/ya/.config/yandex-disk:rw" \
    -v "${ROOT}/config.cfg:/ya/.config/yandex-disk/config.cfg:rw" \
    -e LC_ALL=C.UTF-8 \
    -e "__EXCLUDE__=$__EXCLUDE__" \
    -e "HOME=/ya" \
    "$IMAGE" \
    yandex-disk start \
    --no-daemon \
    --dir=/ya/disk \
    --exclude-dirs="$__EXCLUDE__"
  #    \
  #    --overwrite --read-only
  #    --config=/app/config.cfg \
  #    --auth=/ya/config/passwd \
  ;;
*)
  __info__ "Command not passed"
  help
  ;;

esac
