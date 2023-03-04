#!/bin/sh

echo "[DEBU] ======================== INSTALL PKI ========================"
echo "[DEBU] file name      = ${PWD}/$0"
echo "[DEBU] __PKI_DIR__    = ${__PKI_DIR__}"
echo "[DEBU] __SECRET_TA__  = ${__SECRET_TA__}"
echo "[DEBU] ======================== ----------- ========================"

[ -d "$__PKI_DIR__" ] &&
  [ "$(find "$__PKI_DIR__" -maxdepth 1 | wc -l)" -gt 1 ] &&
  echo "not an empty dir for pki. path inside docker container: [${__PKI_DIR__}]" &&
  exit 0

if [ ! -d "$__PKI_DIR__" ]; then
  mkdir "$__PKI_DIR__" || exit 1
fi

chmod 0700 "$__PKI_DIR__" || exit 1

TMP_DIR=$(mktemp -d) || exit 1

easyrsa --batch --pki-dir="$TMP_DIR" init-pki || exit 1

cp -r "$TMP_DIR"/* "${__PKI_DIR__}/" || exit 1

easyrsa --batch --pki-dir="$__PKI_DIR__" \
  --req-cn="main-ca-evg" \
  --days="3650" \
  --use-algo="ec" \
  --curve="secp384r1" \
  build-ca nopass || exit 1

if [ ! -f "$__SECRET_TA__" ]; then
  openvpn --genkey --secret "$__SECRET_TA__" || exit 1
fi

# creating key Diffie-Hellman
easyrsa --pki-dir="$__PKI_DIR__" gen-dh
