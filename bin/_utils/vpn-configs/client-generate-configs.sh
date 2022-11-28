#!/bin/sh

# Создать файлы конфигурации подключения клиента

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

CFG_DIR="$(__CORE_VPN_PKI_DIR__)/clients" || exit 1
if [ ! -d "$CFG_DIR" ]; then
  mkdir "$CFG_DIR" || exit 1
fi

TMPL_CFG_FILE=
CN_CERT=
HOST=
PORT=
PROTOCOL=
PREFIX=

parse() {
  HOST=$(echo "$1" | grep -Eio "^[^[:space:]]+")
  PORT=$(echo "$1" | grep -Eio "[[:space:]]\d+[[:space:]]" | grep -Eo "\d+")
  PROTOCOL=$(echo "$1" | grep -Eio "[^[:space:]]+$")
  PREFIX=$(echo "$HOST" | grep -Eio -q "^[a-z]+" && echo "$HOST" | grep -Eio "^[^.]+" || echo "$HOST")
}

gen_cfg() {
  parse "$1"
  file="${CFG_DIR}/${PREFIX}-${PORT}-${PROTOCOL}.ovpn"

  sh "${ROOT}/client-openvpn.sh" \
    "$TMPL_CFG_FILE" \
    "evgio-client5" \
    "$file" \
    "$HOST" "$PORT" "$PROTOCOL" "$__DRY_ARG__" "$__DEBUG_ARG__"
  #  echo ">> host  = $HOST  port=$PORT   protocol=$PROTOCOL   . prefix=$PREFIX,  file=$file"
}

# конфигурации для macos / ipad / android
CN_CERT="evgio-client5"
TMPL_CFG_FILE="${ROOT}/cfg/client-macos-tmpl.ovpn"

gen_cfg "kz2.evgio.dev 443 tcp"
gen_cfg "kz2.evgio.dev 443 udp"
gen_cfg "kz2.evgio.dev 33440 tcp"

gen_cfg "eu1.evgio.dev 443 tcp"
gen_cfg "eu1.evgio.dev 443 udp"
gen_cfg "eu1.evgio.dev 33440 tcp"

gen_cfg "rr4.evgio.dev 443 tcp"
gen_cfg "rr4.evgio.dev 443 udp"
gen_cfg "rr4.evgio.dev 33440 tcp"

gen_cfg "msk1.evgio.dev 443 tcp"
gen_cfg "msk1.evgio.dev 443 udp"
gen_cfg "msk1.evgio.dev 33440 tcp"

gen_cfg "spb.evgio.dev 443 tcp"
gen_cfg "spb.evgio.dev 443 udp"
gen_cfg "spb.evgio.dev 33440 tcp"
