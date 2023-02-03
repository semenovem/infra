#!/bin/sh

# Создает файл конфигурации vpn для клиента
#
# $1. шаблон конфигурации (существующий файл)
# $2. CN сертификата
# $3. создаваемый файл конфигурации клиента vpn (не существующий файл)
# $4. хост подключения
# $5. порт подключения
# $6. протокол подключения

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

PKI_DIR=$(__CORE_VPN_PKI_DIR__) || exit 1

TMPL_CFG_FILE=$1
CN_CERT=$2
CFG_FILE=$3
HOST=$4
PORT=$5
PROTOCOL=$6

debug() {
  __debug__ "info: "
  __debug__ "TMPL_CFG_FILE  = ${TMPL_CFG_FILE}"
  __debug__ "CN_CERT        = ${CN_CERT}"
  __debug__ "CFG_FILE       = ${CFG_FILE}"
  __debug__ "HOST           = ${HOST}"
  __debug__ "PORT           = ${PORT}"
  __debug__ "PROTOCOL       = ${PROTOCOL}"
}

[ -n "$__DEBUG__" ] && debug

ERR=
[ -z "$PROTOCOL" ] && ERR=1 && __err__ "не передан протокол подключения"
[ -z "$PORT" ] && ERR=1 && __err__ "не передан порт подключения"
[ -z "$HOST" ] && ERR=1 && __err__ "не передан адрес подключения"
[ -z "$CFG_FILE" ] && ERR=1 && __err__ "не передан файл конфигурации"
[ -z "$CN_CERT" ] && ERR=1 && __err__ "не передан CN сертификата"
[ -z "$TMPL_CFG_FILE" ] && ERR=1 && __err__ "не передан файл-шаблона конфигурации"

[ -n "$TMPL_CFG_FILE" ] && [ ! -f "$TMPL_CFG_FILE" ] && ERR=1 && __err__ "нет файла-шаблона конфигурации [$TMPL_CFG_FILE]"
[ -n "$CFG_FILE" ] && [ -f "$CFG_FILE" ] && ERR=1 && __warn__ "файл конфигурации уже создан [$CFG_FILE]"
[ -n "$ERR" ] && exit 1

[ -n "$__DRY_ARG__" ] && exit 0

{
  echo "# autogenerate $(date)" >"$CFG_FILE"

  while read -r row; do
    [ -z "$row" ] && continue
    echo "$row" | grep -iEq '^[#;]' && continue

    echo "$row" | grep -Eiq '^remote' && row="remote ${HOST} ${PORT}"
    echo "$row" | grep -Eiq '^proto' && row="proto ${PROTOCOL}"

    echo "$row"
  done <"$TMPL_CFG_FILE"

  echo ""
  echo "<ca>"
  cat "${PKI_DIR}/ca.crt"
  echo "</ca>"
  echo "<cert>"
  cat "${PKI_DIR}/issued/${CN_CERT}.crt"
  echo "</cert>"
  echo "<key>"
  cat "${PKI_DIR}/private/${CN_CERT}.key"
  echo "</key>"
  echo "<tls-crypt>"
  cat "${PKI_DIR}/ta.key"
  echo "</tls-crypt>"

} >>"$CFG_FILE"
