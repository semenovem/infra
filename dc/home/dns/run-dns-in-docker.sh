#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

echo "run nginx"

docker run -it --rm \
  -p 53:53 \
  -v "${ROOT}/db.10:/etc/bind/db.10:ro" \
  -v "${ROOT}/db.home.local:/etc/bind/db.home.local:ro" \
  -v "${ROOT}/named.conf.local:/etc/bind/named.conf.local:ro" \
  ubuntu:22.04 bash


# apt-get update && \
#     apt-get -y upgrade && \
#     DEBIAN_FRONTEND=noninteractive apt-get -y install bind9 && \
#     apt-get -y autoremove && \
#     apt-get -y clean && \
#     rm -rf /var/lib/apt/lists/*
