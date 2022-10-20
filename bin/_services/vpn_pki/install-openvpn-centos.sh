#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_core/conf.sh" || exit 1

#sudo systemctl list-units 'openvpn-server*' -all
#ssh -t adman@176.53.162.51 -p 2257 sudo ls /etc/openvpn/

DIR="/Volumes/dat/_environment/dev/openvpn/easy-rsa/configs/evgio-server3-evg"

CA_CERT_FILE="${DIR}/ca.crt"
SERVER_CERT_FILE="${DIR}/server.crt"
SERVER_KEY_FILE="${DIR}/server.key"
TA_KEY_FILE="${DIR}/ta.key"

TARGET_DIR="/etc/openvpn/server"

__info__ "zdfadfsd"

exit

# копировать содержимое файла на удаленный сервер
copy_to_server() {
  file=$1
  to=$2

  [ -z "$file" ] && __err__ "Не передан аргумент \$1 - путь к файлу-источника" && return 1
  [ ! -f "$file" ] && __err__ "Нет файла [$file]" && return 1
  [ -z "$to" ] && __err__ "Не передан аргумент \$2 - путь к файлу-назначения" && return 1

  # shellcheck disable=SC2002
  cat "$file" | ssh adman@176.53.162.51 -p 2257 "sudo tee ${to} >/dev/null"
}

# авторизационные данные
copy_to_server "$CA_CERT_FILE" "${TARGET_DIR}/ca.crt"
copy_to_server "$SERVER_CERT_FILE" "${TARGET_DIR}/server.crt"
copy_to_server "$SERVER_KEY_FILE" "${TARGET_DIR}/server.key"
copy_to_server "$TA_KEY_FILE" "${TARGET_DIR}/ta.key"

# файлы настройки
# скопировать

#

