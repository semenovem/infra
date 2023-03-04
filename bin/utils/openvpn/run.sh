#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

OPENVPN_PKI_DIR="${HOME}/.openvpn_pki" # Инфраструктура ключей openvpn
IMAGE="envi/easy_rsa:1.0"
DOCKER_CMD=$(__core_get_virtualization_app__) || exit 1
OPER="$1"
PKI_NAME=$2
CN_NAME=$3 # Common Name of certificate
PKI_DIR="${OPENVPN_PKI_DIR}/pki-${PKI_NAME}"
CRYPTO_DIR="$OPENVPN_PKI_DIR"

help() {
  __info__ "install name-pki          - установка"
  __info__ "issue   name-pki cn-cert  - выпуск сертификата"
  __info__ "  name-pki  - имя директории с инфраструктурой ключей"
  __info__ "  cn-cert   - имя сертификата"
}

if [ ! -d "$OPENVPN_PKI_DIR" ]; then
  mkdir "$OPENVPN_PKI_DIR" || exit 1
  chmod 0700 "$OPENVPN_PKI_DIR" || exit 1
fi

__core_has_docker_image__ "$IMAGE"
case $? in
0) ;;
1)
  __info__ "Build docker image in progress..."
  [ -n "$__DRY__" ] && exit 0
  $DOCKER_CMD build -f "${ROOT}/easy_rsa.dockerfile" -t "$IMAGE" "$ROOT" || exit 1
  ;;
*) exit 1 ;;
esac

# 1. установка pki инфраструктуры
# 2. создание сертификатов сервера + клиента
# 3. копирование данных на удаленный сервер
#
#

check() {
  [ -z "$PKI_NAME" ] && __err__ "не передано имя директории pki" && return 1
  return 0
}

execute() {
  $DOCKER_CMD run -it --rm \
    --user "$(id -u):$(id -g)" \
    -w /app \
    -e "__PKI_DIR__=/app/pki" \
    -e "__CRYPTO_DIR__=/app/crypto" \
    -e "__SECRET_TA__=/app/pki/ta.key" \
    -e "__CN__=${CN_NAME}" \
    -v "${PKI_DIR}:/app/pki:rw" \
    -v "${CRYPTO_DIR}:/app/crypto:rw" \
    -v "${ROOT}/oper/install-pki.sh:/app/install-pki.sh:ro" \
    -v "${ROOT}/oper/issue-server.sh:/app/issue-server.sh:ro" \
    -v "${ROOT}/oper/issue-client.sh:/app/issue-client.sh:ro" \
    -v "${ROOT}/cfg/:/app/cfg:ro" \
    "$IMAGE" $@
}

# =========================================================

case "$OPER" in
# Установка инфраструктуры PKI
"install")
  check || exit 1

  if [ ! -d "$PKI_DIR" ]; then
    mkdir "$PKI_DIR" || exit 1
    chmod 0700 "$PKI_DIR" || exit 1
  fi

  execute sh install-pki.sh
  ;;

  # Выпуск сертификата с указанным CN (Common Name)
  # Если сертификат уже существует - вернет существующее значение
"issue")
  check || exit 1
  [ ! -d "$PKI_DIR" ] && __err__ "директория [${PKI_DIR}] не существует" && exit 1

  CRYPTO_DIR="${OPENVPN_PKI_DIR}/client-${PKI_NAME}-${CN_NAME}"
  if [ ! -d "$CRYPTO_DIR" ]; then
    mkdir "$CRYPTO_DIR" || exit 1
    chmod 0700 "$CRYPTO_DIR" || exit 1
  fi

    execute bash
  ;;

*help | *h) help && exit 0 ;;
*)
  [ -z "$OPER" ] && help && exit 0
  __err__ "argument not defined: '$OPER'"
  ;;
esac
