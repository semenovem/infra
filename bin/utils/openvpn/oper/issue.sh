#!/bin/sh

ERR=
[ -z "$__PKI_DIR__" ] && ERR=1 && echo "empty __PKI_DIR__"
[ -z "$__CRYPTO_DIR__" ] && ERR=1 && echo "empty __CRYPTO_DIR__"
[ -z "$__CFG_DIR__" ] && ERR=1 && echo "empty __CFG_DIR__"
[ -z "$__PKI_NAME__" ] && ERR=1 && echo "empty __PKI_NAME__"
[ "$__CN__" = "ca" ] && ERR=1 && echo "нельзя использовать __CN__=ca"

[ "$1" = "server" ] && TYPE="server" && __CN__="server-${__PKI_NAME__}"
[ "$1" = "client" ] && TYPE="client"
[ -z "$TYPE" ] && ERR=1 && echo "не валидная команда use [client|server]"

[ -z "$__CN__" ] && ERR=1 && echo "empty __CN__"

echo "[DEBU] ======================== ISSUE CERT ========================"
echo "[DEBU] file name      = ${PWD}/$0"
echo "[DEBU] TYPE           = ${TYPE}"
echo "[DEBU] __CN__         = ${__CN__}"
echo "[DEBU] __PKI_DIR__    = ${__PKI_DIR__}"
echo "[DEBU] __CRYPTO_DIR__ = ${__CRYPTO_DIR__}"
echo "[DEBU] __CFG_DIR__    = ${__CFG_DIR__}"
echo "[DEBU] __PKI_NAME__   = ${__PKI_NAME__}"
echo "[DEBU] ======================== ---------- ========================"

[ -n "$ERR" ] && exit 1

# ===================================================================

# Выпуск сертификата для TYPE = [client | server]
issue_cert() {
  [ -f "${__PKI_DIR__}/issued/${__CN__}.crt" ] && return 0

  easyrsa --batch --pki-dir="$__PKI_DIR__" \
    --req-cn="$__CN__" \
    --days="365" \
    --use-algo="ec" \
    --curve="prime256v1" \
    --digest="sha512" \
    gen-req "$__CN__" nopass || return 1

  easyrsa --batch --pki-dir="$__PKI_DIR__" sign-req "$TYPE" "$__CN__" || return 1
}

# ====================================================================
# =========================      SERVER      =========================
# ====================================================================

# Подготовка набора данных для сервера
if [ "$TYPE" = "server" ]; then
  CRYPTO_DIR="${__CRYPTO_DIR__}/${__PKI_NAME__}-server"

  if [ ! -d "$CRYPTO_DIR" ]; then
    mkdir "$CRYPTO_DIR" || exit 1
    chmod 0700 "$CRYPTO_DIR" || exit 1
  fi

  issue_cert || exit 1

  cp "${__PKI_DIR__}/private/${__CN__}.key" "${CRYPTO_DIR}/server.key"
  cp "${__PKI_DIR__}/issued/${__CN__}.crt" "${CRYPTO_DIR}/server.crt"
  cp "${__PKI_DIR__}/ca.crt" "${CRYPTO_DIR}"
  cp "${__PKI_DIR__}/ta.key" "${CRYPTO_DIR}"
  cp "${__CFG_DIR__}/server-tcp.conf" "${CRYPTO_DIR}"
  cp "${__CFG_DIR__}/server-udp.conf" "${CRYPTO_DIR}"

  # собрать все в архив
  tar -zcf "${__CRYPTO_DIR__}/${__PKI_NAME__}-server.tar.gz" -C "${CRYPTO_DIR}" .
  chmod 0600 "${__CRYPTO_DIR__}/${__PKI_NAME__}-server.tar.gz"

  exit 0
fi

# ===================================================================
# =========================      CLIENT     =========================
# ===================================================================

# Подготовка файла конфигурации клиента
if [ "$TYPE" = "client" ]; then

  issue_cert || exit 1

  sh build-client-cfg.sh \
    "$__PKI_DIR__" \
    "${__CFG_DIR__}/client-linux-tmpl.ovpn" \
    "$__CN__" \
    "${__CRYPTO_DIR__}/${__PKI_NAME__}-${__CN__}-linux.ovpn" \
    "msk1.evgio.com" \
    "1194" \
    "tcp"

  sh build-client-cfg.sh \
    "$__PKI_DIR__" \
    "${__CFG_DIR__}/client-macos-tmpl.ovpn" \
    "$__CN__" \
    "${__CRYPTO_DIR__}/${__PKI_NAME__}-${__CN__}-macos.ovpn" \
    "msk1.evgio.com" \
    "1194" \
    "tcp"
fi
