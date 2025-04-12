#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
ARGUMENTS=

CONST_PROJ_CORE="hq47"
CONST_PROJ_MINIDLNA="hq47-minidlna" ## TODO

ALL_PROJS="${CONST_PROJ_CORE} ${CONST_PROJ_METUBE} ${CONST_PROJ_MINIDLNA} "


func_help() {
  echo "allow commands: [up|down|clean|logs|curl] projects: [all|core|minidlna]"
}

if [ "$#" -eq 0 ]; then
  docker stats --no-stream
  echo ""
  func_help

  exit 0
fi


func_create_networks() {
  for net_name in net-hq47; do
    net_id=$(docker network ls -f "name=${net_name}" -q) || return 1
    [ -n "$net_id" ] && return 0
    
    docker network create --attachable "$net_name" || return 1
  done
}

if [ "$1" = "up" ]; then 
  # func_create_networks || exit
  
  docker compose -p "hr47" --project-directory "$ROOT" \
    -f "${ROOT}/service.yaml" \
    --parallel=2 up --quiet-pull --detach

  exit
fi

if [ "$1" = "down" ]; then 
  docker compose -p "hr47" down

  exit
fi
