#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

export __INFRA_PKI_DIRS__="${__CORE_LOCAL_DIR__}/pki_openvpn" # Инфраструктура ключей openvpn
IMAGE="envi/easy_rsa:1.0"

OPER="$1" # Command
shift

PKI_NAME= # Repository with pki
CN_NAME=  # Common Name of certificate
SERVER=   # server name
ERR=
PKI_DIR=

help() {
  echo '======================== MANAGE VPN SETTINGS ========================'
  echo 'install -pki {name}         - установка'
  echo 'issue -pki {name} -cn {cn}  - выпуск сертификата'
  echo 'ls                          - список репозиториев'
  echo 'ls -pki {name}              - список сертификатов в репозитории'
  echo 'revoke -pki {name} -cn {cn} - отозвать сертификат'
  echo ''
  echo 'common properties:'
  echo '  -pki     - имя репозитория (директории с инфраструктурой ключей)'
  echo '  -cn      - имя сертификата'
  echo '  -server  - имя сервера'
  echo ''
  echo 'bash -pki {name} - зайти в контейнер'
  echo ''
  echo 'Установка и обслуживание openvpn:'
  echo 'openvpn-status  -server {name} [-vpn-service {name}] - статус службы openvpn на сервере'
  echo 'openvpn-install -server {name}  - установить/обновить службу openvpn на сервер'
  echo 'openvpn-stop    -server {name}  - установить/обновить службу openvpn на сервер'
  echo 'update-crl      -server {name}  - обновить отозванные сертификаты crt.pem'
  echo ''
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
  docker run -it --rm \
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
    -v "${ROOT}/pki/install-pki.sh:/app/install-pki.sh:ro" \
    -v "${ROOT}/pki/issue.sh:/app/issue.sh:ro" \
    -v "${ROOT}/pki/revoke.sh:/app/revoke.sh:ro" \
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
    "-server") SERVER="$p" ;;
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
# зайти в докер
"bash") execute bash || exit 1 ;;

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

    echo "list of certs in PKI [${PKI_NAME}]:"

    for f in "${PKI_DIR}/issued/"*; do
      f="$(basename "$f")"
      echo "${f%.*}"
    done
  else
    echo "list of pki dirs:"
    for f in "${__INFRA_PKI_DIRS__}/"*; do echo "$(basename "$f")"; done
  fi
  ;;

"cp") # копировать сертификаты для openvpn на сервер
  echo "  PKI_NAME = $PKI_NAME"
  echo "  SERVER   = $SERVER"
  __confirm__ "copy to server '${SERVER}:~/openvpn-server-dat' ?" || exit 0
  check_arg_pki || exit 1
  check_pki_dir_exists || exit 1
  ssh rr4 "mkdir -p ~/openvpn-server-dat && chmod 0700 ~/openvpn-server-dat"
  scp "${PKI_DIR}/ta.key" \
    "${PKI_DIR}/issued/server.crt" \
    "${PKI_DIR}/ca.crt" \
    "${PKI_DIR}/private/server.key" \
    "${SERVER}:~/openvpn-server-dat"
  ;;

  # подготовка и копирование на сервер конфигов openvpn
  # для 443 tcp/udp 33443 tcp/udp

  # установка сервера vpn - копирование сертификатов/конфигов в директорию

  # проверка статуса работы openvpn на удаленном сервере и локально

  # подготовка конфига-клиента для openvpn

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
