#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

IMAGE="envi/ya-cloud:0.0"
DISK_DIR="/mnt/raid4t_hard/ya.cloud"
YA_CONFIG_DIR="${HOME}/.config/yandex-disk"
CMD=$(__core_get_virtualization_app__) || exit 1

__core_has_docker_image__ "$IMAGE"
case $? in
0) ;;
1)
  [ -n "$__DRY__" ] && __info__ "сборка образа [$IMAGE]" && exit 0
  $CMD build --platform=linux/amd64 \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -f "${ROOT}/ya-debian.dockerfile" \
    -t "$IMAGE" \
    "$ROOT" || exit 1
  ;;
*) exit 1 ;;
esac

if [ ! -d "$YA_CONFIG_DIR" ]; then
  mkdir -p "$YA_CONFIG_DIR" || exit 1
fi

docker run --detach --restart unless-stopped --platform=linux/amd64 \
  --name ya-disk \
  -w /ya \
  -u "$(id -u):$(id -g)" \
  --memory=500m \
  --memory-swap=500m \
  --memory-reservation=250m \
  --cpus=0.3 \
  -v "${DISK_DIR}:/ya/disk:rw" \
  -v "${ROOT}/config.cfg:/home/app/.config/yandex-disk/config.cfg:rw" \
  -v "${YA_CONFIG_DIR}:/home/app/.config/yandex-disk:rw" \
  "$IMAGE" yandex-disk start --no-daemon --dir=/ya/disk
