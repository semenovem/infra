#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

export __INFRA_PKI_DIRS__="${HOME}/_infra_pki_openvpn" # Инфраструктура ключей openvpn
IMAGE="envi/easy_rsa:1.0"
DOCKER_CMD=$(__core_get_virtualization_app__) || exit 1

OPER="$1" # Command
shift

PKI_NAME=               # Repository with pki
CN_NAME=                # Common Name of certificate
export __SERVER__=      # server name
export __VPN_SERVICE__= # vpn service name
ERR=
PKI_DIR=

help() {
  __info__ 'help:'
  __info__ 'install -pki {name}         - установка'
  __info__ 'issue -pki {name} -cn {cn}  - выпуск сертификата'
  __info__ 'ls                          - список репозиториев'
  __info__ 'ls -pki {name}              - список сертификатов в репозитории'
  __info__ 'revoke -pki {name} -cn {cn} - отозвать сертификат'
  __info__ ''
  __info__ ''
  __info__ 'common properties:'
  __info__ '  -pki     - имя репозитория (директории с инфраструктурой ключей)'
  __info__ '  -cn      - имя сертификата'
  __info__ '  -server  - имя сервера'
  __info__ ''
  __info__ 'Установка и обслуживание openvpn:'
  __info__ 'openvpn-status  -server {name} [-vpn-service {name}] - статус службы openvpn на сервере'
  __info__ 'openvpn-install -server {name}  - установить/обновить службу openvpn на сервер'
  __info__ 'openvpn-stop    -server {name}  - установить/обновить службу openvpn на сервер'
  __info__ 'update-crl      -server {name}  - обновить отозванные сертификаты crt.pem'
  __info__ ''
  __info__ ''
}

args() {
  __info__ 'arguments: '
  __info__ "PKI_NAME    = ${PKI_NAME}"
  __info__ "CN_NAME     = ${CN_NAME}"
  __info__ "__SERVER__      = ${__SERVER__}"
  __info__ "__VPN_SERVICE__ = ${__VPN_SERVICE__}"
}

if [ ! -d "$__INFRA_PKI_DIRS__" ]; then
  mkdir "$__INFRA_PKI_DIRS__" || exit 1
  chmod 0700 "$__INFRA_PKI_DIRS__" || exit 1
fi

__core_build_docker_image_if_not__ "$IMAGE" "${ROOT}/easy-rsa.dockerfile" "$ROOT"

check_arg_pki() {
  [ -z "$PKI_NAME" ] && __err__ "[PKI_NAME] pki name not passed" && return 1
  return 0
}

check_arg_cn_cert() {
  [ -z "$CN_NAME" ] && __err__ "[CN_CERT] cn-cert name not passed" && return 1
  return 0
}

check_pki_dir_exists() {
  [ ! -d "$PKI_DIR" ] && __err__ "dir PKI [${PKI_NAME}] no exists" && return 1
  return 0
}

execute() {
  check_pki_dir_exists || return 1

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
    -v "${__INFRA_PKI_DIRS__}:/app/crypto:rw" \
    -v "${ROOT}/oper/install-pki.sh:/app/install-pki.sh:ro" \
    -v "${ROOT}/oper/issue.sh:/app/issue.sh:ro" \
    -v "${ROOT}/oper/revoke.sh:/app/revoke.sh:ro" \
    "$IMAGE" $@
}

# ------------------------------------------------
# --------------      arguments     --------------
# ------------------------------------------------
PREV=
for p in "$@"; do
  if [ -n "$PREV" ]; then
    case "$PREV" in
    "-pki") PKI_NAME="$p" ;;
    "-cn") CN_NAME="$p" ;;
    "-server") __SERVER__="$p" ;;
    "-vpn-service") __VPN_SERVICE__="$p" ;;
    *)
      ERR=1
      err "Unknown argument '${PREV}' '${p}'"
      ;;
    esac

    PREV=
    continue
  fi

  case "$p" in
  "-pki" | "-cn" | "-server" | "-vpn-service") PREV="$p" ;;
  *)
    ERR=1
    __err__ "Unknown argument '${p}'"
    ;;
  esac
done

unset PREV p
[ -n "$ERR" ] && exit 1

[ -n "$PKI_NAME" ] && PKI_DIR="${__INFRA_PKI_DIRS__}/${PKI_NAME}"

# ------------------------------------------------
# --------------     operations     --------------
# ------------------------------------------------

case "$OPER" in
"args") args ;;
"dev") execute sh ;;

"install") # Установка инфраструктуры PKI
  check_arg_pki || exit 1

  if [ ! -d "$PKI_DIR" ]; then
    mkdir "$PKI_DIR" || exit 1
    chmod 0700 "$PKI_DIR" || exit 1
  fi

  execute sh install-pki.sh || exit 1
  execute sh issue.sh server || exit 1
  ;;

"issue") # Выпуск сертификата с указанным CN (Common Name)
  check_arg_pki || exit 1
  check_arg_cn_cert || exit 1
  execute sh issue.sh client
  ;;

"revoke") # Отзыв сертификата с указанным CN (Common Name)
  check_arg_pki || exit 1
  check_arg_cn_cert || exit 1
  execute sh revoke.sh client
  ;;

"ls") # Список репозиториев и клиентских сертификатов
  if [ -n "$PKI_DIR" ]; then
    check_pki_dir_exists || exit 1

    __info__ "list of certs in PKI [${PKI_NAME}]:"

    for f in "${PKI_DIR}/issued/"*; do
      f="$(basename "$f")"

      echo "$f" | grep -Evq '^server.*' || continue
      __info__ "${f%.*}"

    done
  else
    __info__ "list of pki dirs:"
    for f in "${__INFRA_PKI_DIRS__}/"*; do __info__ "$(basename "$f")"; done
  fi
  ;;

"openvpn-status")
  sh "${ROOT}/openvpn-oper.sh" "status"
  ;;

"openvpn-update-crl")
  sh "${ROOT}/openvpn-oper.sh" "update-crl"
  ;;

*)
  [ -z "$OPER" ] && help && exit 0
  __err__ "unknown command: [$OPER]"
  ;;
esac
