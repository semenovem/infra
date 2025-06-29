#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

echo "run docker pull certbot/certbot:v2.11.0"

# echo "__INFRA_LOCAL__=$__INFRA_LOCAL__"

# exit 0

docker run -it --rm \
  -v "${__INFRA_LOCAL__}/certbot/www:/var/www/certbot:rw" \
  -v "${__INFRA_LOCAL__}/certbot/conf:/etc/letsencrypt:rw" \
  certbot/certbot:v2.11.0 \
  certonly --webroot --webroot-path /var/www/certbot -d grafana.evgio.com

echo ">>>>? [INFO] exit_code=$?"


docker run -it --rm \
  -v "${__INFRA_LOCAL__}/certbot/www:/var/www/certbot:rw" \
  -v "${__INFRA_LOCAL__}/certbot/conf:/etc/letsencrypt:rw" \
  certbot/certbot:v2.11.0 \
  certonly --webroot --webroot-path /var/www/certbot -d cloud.evgio.com


docker run -it --rm \
  -v "${__INFRA_LOCAL__}/certbot/www:/var/www/certbot:rw" \
  -v "${__INFRA_LOCAL__}/certbot/conf:/etc/letsencrypt:rw" \
  certbot/certbot:v2.11.0 \
  certonly --webroot --webroot-path /var/www/certbot -d git.evgio.com


docker run -it --rm \
  -v "${__INFRA_LOCAL__}/certbot/www:/var/www/certbot:rw" \
  -v "${__INFRA_LOCAL__}/certbot/conf:/etc/letsencrypt:rw" \
  certbot/certbot:v2.11.0 \
  certonly --webroot --webroot-path /var/www/certbot -d cam.evgio.com

# reload config nginx
docker exec -it core-nginx nginx -s reload
