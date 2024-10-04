#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

echo "run nginx"

docker run -it --rm \
  -p 80:80 \
  -p 443:443 \
  -v "${ROOT}/conf:/etc/nginx/conf.d:ro" \
  -v "${__INFRA_LOCAL__}/certbot/www:/var/www/certbot:ro" \
  -v "${__INFRA_LOCAL__}/certbot/conf/:/etc/nginx/ssl:ro" \
  nginx:1.27.1-bookworm-perl bash
