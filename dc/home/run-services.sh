#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")


func_create_networks() {
  for net_name in net-home; do
    # net-home-torrent net-home-opensearch; do

    net_id=$(docker network ls -f "name=${net_name}" -q) || return 1
    [ -n "$net_id" ] && return 0
    docker network create --attachable "$net_name" || return 1
  done
}

for ARG in "$@"; do
  case "$ARG" in
  "up")
    echo "[INFO] run home services"

    func_create_networks

      set -o allexport
      . "${__INFRA_LOCAL__}/services.env" || exit 1
      set +o allexport

    export OPENSEARCH_INITIAL_ADMIN_PASSWORD=123456!!@@QQww

    docker compose -p home --project-directory "$ROOT" \
      -f "${ROOT}/home-services.yaml" \
      --parallel=2 \
      up --quiet-pull --detach
    ;;

  "logs")
    docker compose -p home logs -f
    ;;

  "curl")
    docker run -it --rm --network net-home-opensearch curlimages/curl:8.10.1 sh
    ;;

  "down")
    echo "[INFO] stop home services"

    docker compose -p home down
    ;;

  "clean")
    docker system prune -f
    for id in $(docker volume ls --filter name="home" -q); do
      docker volume rm "$id"
    done
    ;;

  *)
    echo "[ERRO] unknown command [$ARG] - allow [up|down|clean|logs|curl]"
    exit 1
    ;;
  esac
done
