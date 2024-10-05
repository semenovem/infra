#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")


func_create_networks() {
  for net_name in net-home-nextcloud net-home-gitlab net-home-yadisk net-home-minidlna net-home-torrent; do
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

    docker compose -p home --project-directory "$ROOT" \
      -f "${ROOT}/home-services.yaml" \
      up --quiet-pull --detach
    ;;

  "logs")
    docker compose -p home logs -f
    ;;

  "down")
    echo "[INDO] stop home services"

    docker compose -p home down
    ;;

  "clean")
    docker system prune -f
    for id in $(docker volume ls --filter name="home" -q); do
      docker volume rm "$id"
    done
    ;;

  *)
    echo "[ERRO] unknown command [up|down|clean]"
    ;;
  esac
done
