#!/bin/sh

SERVER1_CN="evgio-server1-evg"
SERVER2_CN="evgio-server2-evg"
SERVER3_CN="evgio-server3-evg"

server_issue_cert() {
  name=$1

  easyrsa --batch --pki-dir="$__PKI_DIR__" \
    --req-cn="$name" \
    --days="365" \
    --use-algo="ec" \
    --curve="prime256v1" \
    --digest="sha512" \
    gen-req "$name" nopass || return 1

  easyrsa --batch --pki-dir="$__PKI_DIR__" sign-req server "$name" || return 1
}

server_issue_cert "$SERVER1_CN"
server_issue_cert "$SERVER2_CN"
server_issue_cert "$SERVER3_CN"
