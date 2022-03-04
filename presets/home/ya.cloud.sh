#!/bin/bash

# TODO work in progress

exit 0

_BIN_=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")
_CMD_=$1
_IMG_="ya.cloud:1"
_IMG_USE_="ya.cloud/ready:1"
_YA_CLOUD_="${_BIN_}/ya.cloud"
_CONTAINER_NAME_="ya-cloud"

function build() {
  local tmp dir rpmPkg
  tmp=$(mktemp) || return 1
  dir=$(mktemp -d) || return 1
  rpkPkg="http://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm"
  curl -L -o "${dir}/yandex.disk.rpm" "$rpkPkg"

# start ---------
cat <<EOF > "${dir}/Dockerfile"
FROM centos:centos8
ENV LC_ALL=C
COPY yandex.disk.rpm yandex.disk.rpm
RUN rpm -ivh yandex.disk.rpm; rm yandex.disk.rpm
CMD bash
EOF
# end -----------

  docker build -f "${dir}/Dockerfile"  -t "$_IMG_" "$dir" || exit 1
}


case $_CMD_ in
  "-build" | "build"  | "--build")
    echo ">>> build"
    build "$@"
  ;;

  *) echo "docker run ..."
    is=$(docker image ls -f=reference="$_IMG_" -q) || exit 1
    [ -z "is" ] && (build || echo "Error build" && exit 1)

    # проверить, запущен ли контейнер
    docker run -it --rm \
      --name "$_CONTAINER_NAME_" \
      -w "/ya.cloud" \
      -v "${_YA_CLOUD_}:/ya.cloud:rw" \
      -v "/etc/passwd:/etc/passwd:ro" \
      -v "/etc/group:/etc/group:ro" \
      "$_IMG_"
esac

# ----------------------------------------------
# ----------------------------------------------
# ----------------------------------------------
exit 0

# https://yandex.ru/support/disk-desktop-linux/start.html
#curl -LO http://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm

# начало работы, настройка
# 1.
# 2.
# 3.
docker run -it --rm \
  --name "ya-cloud-builder" \
  -v "/mnt/raid4t_hard/yandex.cloud/yandex-disk-latest.x86_64.rpm:/tmp/ya.cloud.rpm:ro" \
  centos:centos8 bash -c "rpm -ivh /tmp/ya.cloud.rpm && bash"

docker commit "ya-cloud-builder" "ya.cloud:1"

docker run -it -d \
  --name "ya-cloud" \
  -v "/mnt/raid4t_hard/yandex.cloud/data/:/ya.cloud:rw" \
  -v "/mnt/raid4t_hard/yandex.cloud/config/:/ya.config:rw" \
  -v "/etc/passwd:/etc/passwd:ro" \
  -v "/etc/group:/etc/group:ro" \
  -w "/ya.cloud" \
  -u $(id -u $USER):$(id -g $USER) \
  -e "HOME=/ya.config" \
  "ya.cloud:1" bash

yandex-disk setup
