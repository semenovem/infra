#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

echo "run docker pull certbot/certbot:v2.11.0"

docker run -it --rm \
  -v "${ROOT}/../../.local/certbot/www/:/var/www/certbot/:rw" \
  -v "${ROOT}/../../.local/certbot/conf/:/etc/letsencrypt/:rw" \
  certbot/certbot:v2.11.0 \
  certonly --webroot --webroot-path /var/www/certbot/ -d git.evgio.com

