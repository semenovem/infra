#!/bin/sh

# Создает файл конфигурации vpn для клиента
#
# $1. путь к директории pki
# $2. шаблон конфигурации (существующий файл)
# $3. CN сертификата
# $4. путь к файлу конфигурации клиента vpn (не существующий файл)
# $5. хост подключения
# $6. порт подключения
# $7. протокол подключения

PKI_DIR=$1
TMPL_CFG_FILE=$2
CN_CERT=$3
CFG_FILE=$4
HOST=$5
PORT=$6
PROTOCOL=$7

ERR=
[ -z "$PKI_DIR" ] && ERR=1 && echo "не передан путь к директории pki"
[ -z "$TMPL_CFG_FILE" ] && ERR=1 && echo "не передан файл-шаблона конфигурации"
[ -z "$CN_CERT" ] && ERR=1 && echo "не передан CN сертификата"
[ -z "$CFG_FILE" ] && ERR=1 && echo "не передан файл конфигурации"
[ -z "$HOST" ] && ERR=1 && echo "не передан адрес подключения"
[ -z "$PORT" ] && ERR=1 && echo "не передан порт подключения"
[ -z "$PROTOCOL" ] && ERR=1 && echo "не передан протокол подключения"
[ -n "$TMPL_CFG_FILE" ] && [ ! -f "$TMPL_CFG_FILE" ] && ERR=1 && echo "нет файла-шаблона конфигурации [$TMPL_CFG_FILE]"
[ -n "$CFG_FILE" ] && [ -f "$CFG_FILE" ] && ERR=1 && echo "файл конфигурации уже создан [$CFG_FILE]"

[ -n "$ERR" ] && exit 1

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

chmod 0600 "$CFG_FILE"
