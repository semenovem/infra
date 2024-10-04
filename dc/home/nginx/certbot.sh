#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

echo "run docker pull certbot/certbot:v2.11.0"

docker run -it --rm \
  -v "${__INFRA_LOCAL__}/certbot/www/:/var/www/certbot:rw" \
  -v "${__INFRA_LOCAL__}/certbot/conf/:/etc/letsencrypt:rw" \
  certbot/certbot:v2.11.0 \
  certonly --webroot --webroot-path /var/www/certbot/ -d nextcloud.evgio.com
