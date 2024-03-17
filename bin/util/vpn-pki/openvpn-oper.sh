#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

OPER="$1"
REMOTE_DIR="/etc/openvpn/server"

__info__ "__INFRA_PKI_DIRS__ = $__INFRA_PKI_DIRS__"
__info__ "__OPER__         = $OPER"
__info__ "__SERVER__         = $__SERVER__"
__info__ "__VPN_SERVICE__    = $__VPN_SERVICE__"
__info__ "__PKI_NAME__       = $__PKI_NAME__"

PKI_NAME="$(__run_configurator__ pki -host "$__SERVER__")" || exit 1
SSH_CONN="$(__run_configurator__ ssh-conn -host "$__SERVER__")" || exit 1

__info__ "PKI_NAME = ${PKI_NAME}"
__info__ "SSH_CONN = ${SSH_CONN}"

# копировать содержимое файла на удаленный сервер
copy_to_server() {
  FILE=$1
  TO=$2

  [ -z "$FILE" ] && __err__ "Не передан аргумент \$1 - путь к файлу-источника" && return 1
  [ ! -f "$FILE" ] && __err__ "Нет файла [$FILE]" && return 1
  [ -z "$TO" ] && __err__ "Не передан аргумент \$2 - путь к файлу-назначения" && return 1

  # shellcheck disable=SC2002
  # shellcheck disable=SC2029
  # shellcheck disable=SC2086
  cat "$FILE" | ssh "$SSH_HOST" $SSH_PORT "sudo tee ${TO} >/dev/null"
}

  # подготовка и копирование на сервер конфигов openvpn
  # для 443 tcp/udp 33443 tcp/udp

  # установка сервера vpn - копирование сертификатов/конфигов в директорию

  # проверка статуса работы openvpn на удаленном сервере и локально

  # подготовка конфига-клиента для openvpn

case "$OPER" in
"status")
  __info__ "status"

  sudo systemctl list-units 'openvpn-server*' -all

#  [ -n "$__VPN_SERVICE__" ] && CMD="systemctl status openvpn-server@${__VPN_SERVICE__}" ||
#    CMD="systemctl list-units 'openvpn-server*' -all"
#
#  # shellcheck disable=SC2086
#  ssh $SSH_CONN "$CMD"
  ;;

"install") echo "install" ;;
"stop") echo "stop" ;;

"update-crl")
  __info__ "update crl.pem"
  copy_to_server "${__INFRA_PKI_DIRS__}/${__PKI_NAME__}/crl.pem" "${REMOTE_DIR}/crl.pem"
  ;;

esac
