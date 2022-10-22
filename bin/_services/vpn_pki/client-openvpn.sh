#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_core/conf.sh" || exit 1

CLIENT_CFG_DIR="${__CORE_CONF_VPN_PKI_DIR__}/clients"
if [ ! -d "$CLIENT_CFG_DIR" ]; then
  mkdir "$CLIENT_CFG_DIR" || exit 1
fi

TMPL_NAME="client-macos-tmpl.ovpn"

CN_NAME="evgio-client5"
PRETTY_NAME="mac-kz2.ovpn"
CFG_REMOTE="kz2.evgio.dev 443"
CFG_REMOTE="176.53.162.51 443"
CFG_PROTO="tcp"

CLIENT_CFG_FILE="${CLIENT_CFG_DIR}/${PRETTY_NAME}"

[ ! -d "$__CORE_CONF_VPN_PKI_DIR__" ] &&
  __err__ "empty dir with vpn-pki: [$__CORE_CONF_VPN_PKI_DIR__]" &&
  exit 1

cp "${ROOT}/cfg/${TMPL_NAME}" "$CLIENT_CFG_FILE" || exit 1

{
  echo "proto ${CFG_PROTO}"
  echo "remote ${CFG_REMOTE}"
  echo ""
  echo ""
  echo "<ca>"
  cat "${__CORE_CONF_VPN_PKI_DIR__}/ca.crt"
  echo "</ca>"
  echo ""
  echo "<cert>"
  cat "${__CORE_CONF_VPN_PKI_DIR__}/issued/${CN_NAME}.crt"
  echo "</cert>"
  echo ""
  echo "<key>"
  cat "${__CORE_CONF_VPN_PKI_DIR__}/private/${CN_NAME}.key"
  echo "</key>"
  echo ""
  echo "<tls-crypt>"
  cat "${__CORE_CONF_VPN_PKI_DIR__}/ta.key"
  echo "</tls-crypt>"
} >>"$CLIENT_CFG_FILE"
