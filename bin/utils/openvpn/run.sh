#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

INFRA_PKI_DIR="${HOME}/_envi_openvpn_pki" # Инфраструктура ключей openvpn
IMAGE="envi/easy_rsa:1.0"
DOCKER_CMD=$(__core_get_virtualization_app__) || exit 1
OPER="$1"
PKI_NAME=$2
CN_NAME=$3 # Common Name of certificate
PKI_DIR="${INFRA_PKI_DIR}/${PKI_NAME}-pki"

help() {
  __info__ "install name-pki          - установка"
  __info__ "issue   name-pki cn-cert  - выпуск сертификата"
  __info__ "  name-pki  - \$1 имя директории с инфраструктурой ключей"
  __info__ "  cn-cert   - \$2 имя сертификата"
}

if [ ! -d "$INFRA_PKI_DIR" ]; then
  mkdir "$INFRA_PKI_DIR" || exit 1
  chmod 0700 "$INFRA_PKI_DIR" || exit 1
fi

if [ -n "$PKI_NAME" ] && [ ! -d "$PKI_DIR" ]; then
  mkdir "$PKI_DIR" || exit 1
  chmod 0700 "$PKI_DIR" || exit 1
fi

__core_has_docker_image__ "$IMAGE"
case $? in
0) ;;
1)
  __info__ "Build docker image in progress..."
  [ -n "$__DRY__" ] && exit 0
  $DOCKER_CMD build -f "${ROOT}/easy-rsa.dockerfile" -t "$IMAGE" "$ROOT" || exit 1
  ;;
*) exit 1 ;;
esac

check() {
  [ -z "$PKI_NAME" ] && __err__ "[PKI_NAME] pki directory name not passed" && return 1
  return 0
}

execute() {
  # shellcheck disable=SC2068
  $DOCKER_CMD run -it --rm \
    --user "$(id -u):$(id -g)" \
    -w /app \
    -e "__PKI_DIR__=/app/pki" \
    -e "__CRYPTO_DIR__=/app/crypto" \
    -e "__CFG_DIR__=/app/cfg" \
    -e "__SECRET_TA__=/app/pki/ta.key" \
    -e "__CN__=${CN_NAME}" \
    -e "__PKI_NAME__=${PKI_NAME}" \
    -v "${PKI_DIR}:/app/pki:rw" \
    -v "${INFRA_PKI_DIR}:/app/crypto:rw" \
    -v "${ROOT}/oper/install-pki.sh:/app/install-pki.sh:ro" \
    -v "${ROOT}/oper/issue.sh:/app/issue.sh:ro" \
    -v "${ROOT}/oper/build-client-cfg.sh:/app/build-client-cfg.sh:ro" \
    -v "${ROOT}/cfg/:/app/cfg:ro" \
    "$IMAGE" $@
}

# =========================================================

case "$OPER" in
# Установка инфраструктуры PKI
"install")
  check || exit 1

  execute sh install-pki.sh || exit 1
  execute sh issue.sh server || exit 1
  ;;

  # Выпуск сертификата с указанным CN (Common Name)
"issue")
  check || exit 1
  [ ! -d "$PKI_DIR" ] && __err__ "directory [${PKI_DIR}] does not exist" && exit 1
  [ -z "$CN_NAME" ] && __err__ "empty CN_NAME" && exit 1

  execute sh issue.sh client
  ;;

*help | *h) help && exit 0 ;;
*)
  [ -z "$OPER" ] && help && exit 0
  __err__ "argument not defined: '$OPER'"
  ;;
esac
