#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_core/conf.sh" || exit 1

[ ! -d "$__CORE_CONF_VPN_PKI_DIR__" ] &&
  __err__ "empty dir with vpn-pki: [$__CORE_CONF_VPN_PKI_DIR__]" &&
  exit 1

OPER_COPY_FILES=
OPER_START=
OPER_STOP=

DIR="$__CORE_CONF_VPN_PKI_DIR__"

# TODO это CN серверного комплекта
CN_NAME="evgio-server1-evg"

CA_CERT_FILE="${DIR}/ca.crt"
TA_KEY_FILE="${DIR}/ta.key"

# копировать содержимое файла на удаленный сервер
copy_to_server() {
  file=$1
  to=$2

  [ -z "$file" ] && __err__ "Не передан аргумент \$1 - путь к файлу-источника" && return 1
  [ ! -f "$file" ] && __err__ "Нет файла [$file]" && return 1
  [ -z "$to" ] && __err__ "Не передан аргумент \$2 - путь к файлу-назначения" && return 1

  # TODO подключение по имени из конфига
  # shellcheck disable=SC2002
  cat "$file" | ssh kz2 "sudo tee ${to} >/dev/null"
  #  cat "$file" | ssh adman@176.53.162.51 -p 2257 "sudo tee ${to} >/dev/null"
}

# Копирование файлов
if [ -n "$OPER_COPY_FILES" ]; then
  REMOTE_DIR="/etc/openvpn/server"

  copy_to_server "$TA_KEY_FILE" "${REMOTE_DIR}/ta.key"
  copy_to_server "$CA_CERT_FILE" "${REMOTE_DIR}/ca.crt"
  copy_to_server "${DIR}/issued/${CN_NAME}.crt" "${REMOTE_DIR}/server.crt"
  copy_to_server "${DIR}/private/${CN_NAME}.key" "${REMOTE_DIR}/server.key"

  copy_to_server "${ROOT}/cfg/server-443-tcp.conf" "${REMOTE_DIR}/server-443-tcp.conf"
  copy_to_server "${ROOT}/cfg/server-443-udp.conf" "${REMOTE_DIR}/server-443-udp.conf"
  copy_to_server "${ROOT}/cfg/server-33440-tcp.conf" "${REMOTE_DIR}/server-33440-tcp.conf"
fi

# TODO раздельная инсталяция сервисов по номеру порта

# Остановка / запуск служб
#ssh adman@176.53.162.51 -p 2257 "systemctl list-units 'openvpn-server*' -all"
#ssh adman@176.53.162.51 -p 2257 "sudo systemctl status openvpn-server@server-443-tcp.service"
ssh kz2 "systemctl list-units 'openvpn-server*' -all"

#
exit 0

#
systemctl list-units 'openvpn-server*' -all | grep -i 'openvpn-server' | awk '{print $1}'

systemctl -f enable openvpn-server@server-443-tcp.service
systemctl start openvpn-server@server-443-tcp.service
systemctl status openvpn-server@server-443-tcp.service

systemctl -f enable openvpn-server@server-443-udp.service
systemctl start openvpn-server@server-443-udp.service
systemctl status openvpn-server@server-443-udp.service

systemctl -f enable openvpn-server@server-33440-tcp.service
systemctl start openvpn-server@server-33440-tcp.service
systemctl status openvpn-server@server-33440-tcp.service
