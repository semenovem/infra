#!/bin/bash

# Проверяет наличие образа на хост-машине
# при отсутствии, запускает сборку образов
# arg1 - название docker образа
# arg2 - название docker образа для разработки

BIN=$(dirname $([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}"))
IMG=$1
IMG_DEV=$2
DIR=$3
PROJ_DIR_NAME=$4

check() {
  echo $(docker images --filter=reference="$1" -q)
}

required() {
  if [ -z $(check "$1") ]; then
    echo "Error. No image '$1'"
    exit 1
  fi
}

# проверка docker image
[ -z $(check "$IMG") ] && make -C "${BIN}/.." docker
required "$IMG"

# docker image для разработки
if [ -z $(check "$IMG_DEV") ]; then
  echo "#################################################################"
  echo "# Сервис клиринга                                               #"
  echo "# Сборка образа для разработки с зависимостями                  #"
  echo "## IMG     = $IMG"
  echo "## IMG_DEV = $IMG_DEV"
  echo "## DIR     = $DIR"
  echo "#################################################################"

  ID=$(docker run --rm -d \
    -w "/app/${PROJ_DIR_NAME}" \
    -v "${DIR}":/app:rw \
    "${IMG}" \
    sleep 3600)

  docker exec -it "${ID}" sh -c "go get"
  docker commit -m "Для разработки с установленными зависимостями" "${ID}" "${IMG_DEV}"
  docker container rm -f "${ID}"
fi
required "$IMG_DEV"
