#!/bin/sh

# Отзыв сертификата

ERR=
[ -z "$__PKI_DIR__" ] && ERR=1 && echo "empty __PKI_DIR__"
[ -z "$__CRYPTO_DIR__" ] && ERR=1 && echo "empty __CRYPTO_DIR__"
[ -z "$__PKI_NAME__" ] && ERR=1 && echo "empty __PKI_NAME__"
[ -z "$__CN__" ] && ERR=1 && echo "empty __CN__"

echo "[DEBU] ======================== REVOKE CERT ========================"
echo "[DEBU] file name      = ${PWD}/$0"
echo "[DEBU] __CN__         = ${__CN__}"
echo "[DEBU] __PKI_DIR__    = ${__PKI_DIR__}"
echo "[DEBU] __CRYPTO_DIR__ = ${__CRYPTO_DIR__}"
echo "[DEBU] __PKI_NAME__   = ${__PKI_NAME__}"
echo "[DEBU] ======================== ----------- ========================"

[ -n "$ERR" ] && exit 1

# ===================================================================
[ ! -f "${__PKI_DIR__}/issued/${__CN__}.crt" ] && echo "cert sn=[${__CN__}] not found" && return 1

easyrsa --pki-dir="$__PKI_DIR__" revoke "$__CN__" || exit 1
easyrsa --pki-dir="$__PKI_DIR__" gen-crl

echo "cert cn=${__CN__} revoked"
