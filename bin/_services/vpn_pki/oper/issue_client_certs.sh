#!/bin/sh

CLIENT1_CN="conn-evg"
CLIENT2_CN="conn-mob"
CLIENT3_CN="conn-013"
CLIENT4_CN="evgio-client4"
CLIENT5_CN="evgio-client5"

client_issue_cert() {
  name=$1

  easyrsa --batch --pki-dir="$__PKI_DIR__" \
    --req-cn="$name" \
    --days="365" \
    --use-algo="ec" \
    --curve="prime256v1" \
    gen-req "$name" nopass || return 1

  easyrsa --batch --pki-dir="$__PKI_DIR__" sign-req client "$name" || return 1
}

client_issue_cert "$CLIENT1_CN"
client_issue_cert "$CLIENT2_CN"
client_issue_cert "$CLIENT3_CN"
client_issue_cert "$CLIENT4_CN"
client_issue_cert "$CLIENT5_CN"
