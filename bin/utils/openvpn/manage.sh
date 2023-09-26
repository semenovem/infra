#!/bin/sh

# Настройка proxy сервера
# wip
#
# аргументы:
# -hosts [ список хостов, в формате kz1:port:protocol - например: spb:443:tcp spb:443:udp ]
# -cert-name  - CN серверного сертификата
# -copy     - копировать файлы на удаленный сервер
# -restart  - перезапустить службы openvpn
# -status   - показать статус openvpn

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

PKI_DIR=$(__CORE_VPN_PKI_DIR__) || exit 1

OPER_COPY_FILES=0
SSH_HOST="home"
SSH_PORT=""

help() {
  __info__ "[help] use: [-hosts msk1|rr1|spb|...] [-copy] [-restart] [-status]"
}

#exit 0

# TODO это CN серверного комплекта
CN_NAME="evgio-server1-evg"

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

# Копирование файлов
if [ -n "$OPER_COPY_FILES" ]; then
  REMOTE_DIR="/etc/openvpn/server"

  copy_to_server "${PKI_DIR}/ta.key" "${REMOTE_DIR}/ta.key"
  copy_to_server "${PKI_DIR}/ca.crt" "${REMOTE_DIR}/ca.crt"
  copy_to_server "${PKI_DIR}/issued/${CN_NAME}.crt" "${REMOTE_DIR}/server.crt"
  copy_to_server "${PKI_DIR}/private/${CN_NAME}.key" "${REMOTE_DIR}/server.key"

  copy_to_server "${ROOT}/cfg/server-443-tcp.conf" "${REMOTE_DIR}/server-443-tcp.conf"
  copy_to_server "${ROOT}/cfg/server-443-udp.conf" "${REMOTE_DIR}/server-443-udp.conf"
  copy_to_server "${ROOT}/cfg/server-33440-tcp.conf" "${REMOTE_DIR}/server-33440-tcp.conf"
fi

# TODO раздельная инсталляция сервисов по номеру порта

exit 0

# Остановка / запуск служб
#ssh adman@176.53.162.51 -p 2257 "systemctl list-units 'openvpn-server*' -all"
#ssh adman@176.53.162.51 -p 2257 "sudo systemctl status openvpn-server@server-443-tcp.service"
HOST="kz2"
HOST="eu1"
HOST="spb"
HOST="rr4"
HOST="msk1"

#ssh "$HOST" "systemctl list-units 'openvpn-server*' -all"

#exit 0
#
#ssh "$HOST" systemctl -f enable openvpn-server@server-443-tcp.service
#ssh "$HOST" systemctl start openvpn-server@server-443-tcp.service
#ssh "$HOST" systemctl status openvpn-server@server-443-tcp.service
#
#ssh "$HOST" systemctl -f enable openvpn-server@server-443-udp.service
#ssh "$HOST" systemctl start openvpn-server@server-443-udp.service
#ssh "$HOST" systemctl status openvpn-server@server-443-udp.service
#
#ssh "$HOST" systemctl -f enable openvpn-server@server-33440-tcp.service
#ssh "$HOST" systemctl start openvpn-server@server-33440-tcp.service
#ssh "$HOST" systemctl status openvpn-server@server-33440-tcp.service

#exit 0

ssh "$HOST" 'sudo systemctl restart openvpn-server@server-443-tcp.service'
ssh "$HOST" 'sudo systemctl restart openvpn-server@server-443-udp.service'

#ssh "$HOST" 'sudo systemctl -f enable openvpn-server@server-33440-tcp.service'
#ssh "$HOST" 'sudo systemctl start openvpn-server@server-33440-tcp.service'
#ssh "$HOST" 'sudo systemctl status openvpn-server@server-33440-tcp.service'

ssh "$HOST" 'sudo systemctl restart openvpn-server@server-33440-tcp.service'

#
exit 0

#
systemctl list-units 'openvpn-server*' -all | grep -i 'openvpn-server' | awk '{print $1}'

systemctl -f enable openvpn-server@server-443-tcp.service
systemctl restart openvpn-server@server-443-tcp.service
systemctl status openvpn-server@server-443-tcp.service

systemctl -f enable openvpn-server@server-443-udp.service
systemctl start openvpn-server@server-443-udp.service
systemctl status openvpn-server@server-443-udp.service

systemctl -f enable openvpn-server@server-tcp.service
systemctl stop openvpn-server@server-tcp.service
systemctl start openvpn-server@server-tcp.service
systemctl restart openvpn-server@server-tcp.service
systemctl status openvpn-server@server-tcp.service
