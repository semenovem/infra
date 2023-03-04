#!/bin/sh

NAME="$__CN__"

easyrsa --batch --pki-dir="$__PKI_DIR__" \
  --req-cn="$NAME" \
  --days="365" \
  --use-algo="ec" \
  --curve="prime256v1" \
  --digest="sha512" \
  gen-req "$NAME" nopass || exit 1

easyrsa --batch --pki-dir="$__PKI_DIR__" sign-req client "$NAME" || exit 1

cp "${__PKI_DIR__}/private/${NAME}.key" "${__CRYPTO_DIR__}"
cp "${__PKI_DIR__}/issued/${NAME}.crt" "${__CRYPTO_DIR__}"


