#!/bin/sh

ERR=
[ -z "$__PKI_DIR__" ] && ERR=1 && echo "empty __PKI_DIR__"
[ -z "$__CRYPTO_DIR__" ] && ERR=1 && echo "empty __CRYPTO_DIR__"
[ -z "$__CFG_DIR__" ] && ERR=1 && echo "empty __CFG_DIR__"
[ -z "$__PKI_NAME__" ] && ERR=1 && echo "empty __PKI_NAME__"
[ "$__CN__" = "ca" ] && ERR=1 && echo "can not use __CN__=ca"

case "$1" in
"server") TYPE="server" && __CN__="server" ;;
"client") TYPE="client" ;;
*) ERR=1 && echo "unknown command. Use [client|server]" ;;
esac

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
  [ -f "${__PKI_DIR__}/issued/${__CN__}.crt" ] && echo "cert [${__CN__}] already exists" && return 0

  easyrsa --batch --pki-dir="$__PKI_DIR__" \
    --req-cn="$__CN__" \
    --days="365" \
    --use-algo="ec" \
    --curve="prime256v1" \
    --digest="sha512" \
    gen-req "$__CN__" nopass || return 1

  easyrsa --batch --pki-dir="$__PKI_DIR__" sign-req "$TYPE" "$__CN__" || return 1
}

issue_cert
