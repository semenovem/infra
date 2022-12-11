#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

IMAGE="envi/ya-cloud:0.0"
CMD=$(__core_get_virtualization_app__) || exit 1

__core_has_docker_image__ "$IMAGE"
case $? in
0) ;;
1)
  [ -n "$__DRY__" ] && __info__ "сборка образа [$IMAGE]" && exit 0
  $CMD build --platform=linux/amd64 -f "${ROOT}/ya.dockerfile" -t "$IMAGE" "$ROOT" || exit 1
  ;;
*) exit 1 ;;
esac



[ -n "$__DRY__" ] && __info__ "Запуск контейнера: " && exit 0

docker run --platform=linux/amd64 -it --rm \
  -u "$(id -u):$(id -g)" \
  --name "ya-cloud" \
  -w /qpp \
  --memory=64m \
  --memory-swap=64m \
  --memory-reservation=32m \
  --cpus=0.5 \
  -v "${ROOT}/config.cfg:/ya.config/config.cfg:ro" \
  -v "${HOME}/.config/yandex-disk/passwd:/ya.config/passwd:ro" \
  -v "/mnt/hard/ya.cloud:/ya.cloud:rw" \
  "$IMAGE" bash

# yandex-disk --config=/ya.config/config.cfg
# данные
# файл конфига
#
#
#

#  -v "/mnt/raid4t_hard/yandex.cloud/data/:/ya.cloud:rw" \
#  -v "/mnt/raid4t_hard/yandex.cloud/config/:/ya.config:rw" \
#  -v "/etc/passwd:/etc/passwd:ro" \
#  -v "/etc/group:/etc/group:ro" \
#  -w "/ya.cloud" \
#  -e "HOME=/ya.config" \
