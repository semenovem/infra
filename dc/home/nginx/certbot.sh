#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

echo "__INFRA_LOCAL__=$__INFRA_LOCAL__"
[ -z "$__INFRA_LOCAL__" ] && echo "[ERRO][$0] empty __INFRA_LOCAL__" && exit 1
[ ! -d "$__INFRA_LOCAL__" ] && \
  echo "[ERRO][$0] dir in __INFRA_LOCAL__=${__INFRA_LOCAL__} not exists" && \
  exit 1

for DOMAIN in cloud.evgio.com git.evgio.com grafana.evgio.com cam.evgio.com; do
  docker run -it --rm \
    -v "${ROOT}/.well-known:/var/www/certbot:rw" \
    -v "${__INFRA_LOCAL__}/certbot/conf:/etc/letsencrypt:rw" \
    certbot/certbot:v4.2.0 \
    certonly --quiet --webroot --webroot-path /var/www/certbot -d "$DOMAIN"

  if [ "$?" -eq 0 ]; then
    printf "\033[0;32m[INFO]\033[0m ok [%s]\n" "$DOMAIN"
  else
    printf "\033[31m[ERRO]\033[0m %s\n" "$DOMAIN"
  fi
done

# reload config nginx
docker exec -it core-nginx nginx -s reload

