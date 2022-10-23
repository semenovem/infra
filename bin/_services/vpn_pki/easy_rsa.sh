#!/bin/sh

# Запускает контейнер для работы с easy_rsa

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_core/conf.sh" || exit 1

IMAGE="envi/easy_rsa:1.0"

DOCKER_CMD=$(__core_get_virtualization_app__) || exit 1

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

mkdir -p "$__CORE_CONF_VPN_PKI_DIR__" || exit 1
chmod 0700 "$__CORE_CONF_VPN_PKI_DIR__" || exit 1

$DOCKER_CMD run -it --rm \
  --user "$(id -u):$(id -g)" \
  -w /app \
  -e "__PKI_DIR__=/app/pki" \
  -e "__SECRET_TA__=/app/pki/ta.key" \
  -v "${__CORE_CONF_VPN_PKI_DIR__}:/app/pki:rw" \
  -v "${PWD}/oper/install_pki.sh:/app/install_pki.sh:ro" \
  -v "${PWD}/oper/issue_server_certs.sh:/app/issue_server_certs.sh:ro" \
  -v "${PWD}/oper/issue_client_certs.sh:/app/issue_client_certs.sh:ro" \
  "$IMAGE" bash

# запуск скриптов в запущенном контейнере
#
# sh install_pki.sh
# sh issue_server_certs.sh
# sh issue_client_certs.sh
