#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

INFRA_PKI_DIR="${HOME}/_envi_openvpn_pki" # Инфраструктура ключей openvpn
IMAGE="envi/easy_rsa:1.0"
DOCKER_CMD=$(__core_get_virtualization_app__) || exit 1
OPER="$1"   # Command
PKI_NAME=$2 # Repository with pki
CN_NAME=$3  # Common Name of certificate
[ -n "$PKI_NAME" ] && PKI_DIR="${INFRA_PKI_DIR}/${PKI_NAME}-pki"

help() {
  __info__ 'install name-pki        - установка'
  __info__ 'issue name-pki cn-cert  - выпуск сертификата'
  __info__ 'ls                      - список репозиториев'
  __info__ 'ls name-pki             - список сертификатов в репозитории'
  __info__ 'get name-pki cn-cert    - получить архив с набором крипто-материалов'
  __info__ 'revoke name-pki cn-cert - отозвать сертификат'
  __info__ ''
  __info__ ''
  __info__ 'common properties:'
  __info__ '  name-pki    - имя репозитория (директории с инфраструктурой ключей)'
  __info__ '  cn-cert     - имя сертификата'
}

if [ ! -d "$INFRA_PKI_DIR" ]; then
  mkdir "$INFRA_PKI_DIR" || exit 1
  chmod 0700 "$INFRA_PKI_DIR" || exit 1
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

check_arg_pki() {
  [ -z "$PKI_NAME" ] && __err__ "[PKI_NAME] pki name not passed" && return 1
  return 0
}

check_arg_cn_cert() {
  [ -z "$CN_NAME" ] && __err__ "[CN_CERT] cn-cert name not passed" && return 1
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
"install")
  # Установка инфраструктуры PKI
  check_arg_pki || exit 1

  if [ -n "$PKI_NAME" ] && [ ! -d "$PKI_DIR" ]; then
    mkdir "$PKI_DIR" || exit 1
    chmod 0700 "$PKI_DIR" || exit 1
  fi

  execute sh install-pki.sh || exit 1
  execute sh issue.sh server || exit 1
  ;;

"issue")
  # Выпуск сертификата с указанным CN (Common Name)
  check_arg_pki || exit 1
  check_arg_cn_cert || exit 1

  [ ! -d "$PKI_DIR" ] && __err__ "directory [${PKI_DIR}] does not exist" && exit 1

  execute sh issue.sh client
  ;;

"ls")
  if [ -n "$PKI_DIR" ]; then
    :
    echo "!! > $PKI_DIR"
  else
    # shellcheck disable=SC2010
    ls -l "$INFRA_PKI_DIR" | grep -Ei '\-pki$'
    :
  fi

  ;;

*help | *h) help && exit 0 ;;
*)
  [ -z "$OPER" ] && help && exit 0
  __err__ "argument not defined: '$OPER'"
  ;;
esac
