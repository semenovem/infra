#!/bin/sh

[ -d "$__PKI_DIR__" ] &&
  [ "$(find "$__PKI_DIR__" -maxdepth 1 | wc -l)" -gt 1 ] &&
  echo "not empty dir [${__PKI_DIR__}]" &&
  exit 1

easyrsa --batch --pki-dir="$__PKI_DIR__" init-pki || exit 1

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
