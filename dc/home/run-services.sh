#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
ARGUMENTS=
OPERATION=
PROJECT=
CONST_PROJ_HOME_CORE="home"
CONST_PROJ_HOME_GITLAB="home-gitlab"
CONST_PROJ_HOME_NEXTCLOUD="home-nextcloud"
CONST_PROJ_YA_DISK="home-ya-disk" ## TODO
CONST_PROJ_MINIDLNA="home-minidlna" ## TODO


func_help() {
  echo "allow [up|down|clean|logs|curl|core|gitlab|nextcloud|minidlna]"
}

if [ "$#" -eq 0 ]; then
  docker stats --no-stream
  echo ""
  func_help

  exit 0
fi


func_create_networks() {
  for net_name in net-home; do
    # net-home-torrent net-home-opensearch; do

    net_id=$(docker network ls -f "name=${net_name}" -q) || return 1
    [ -n "$net_id" ] && return 0
    docker network create --attachable "$net_name" || return 1
  done
}

# up down gitlab      => UP gitlab DOWN gitlab
# up gitlab nextcloud => UP gitlab UP nextcloud
# gitlab up logs
# down up gitlab nextcloud logs
# up down gitlab logs nextcloud
func_analysis_arguments() {
  set -- $@ "eof_arg"

  proj_for_logs=
  on_logs=
  items=
  act_type=
  opers=
  projs=

  for arg in "$@"; do
    oper=
    proj=

    case "$arg" in
      "up")   oper="UP"   ;;
      "down") oper="DOWN" ;;
      "logs") on_logs=1; continue ;;

      "core")      proj="$CONST_PROJ_HOME_CORE" ;;
      "gitlab")    proj="$CONST_PROJ_HOME_GITLAB" ;;
      "nextcloud") proj="$CONST_PROJ_HOME_NEXTCLOUD" ;;

      "eof_arg") ;;
      "clean" | "curl" | "minidlna") items="${arg} ${items}"; continue ;;
      *)
        echo "[ERRO] unknown [$arg] - $(func_help)"
        return 1
      ;;
    esac

    swit=
    [ -n "$proj" ] && swit="proj" && proj_for_logs="$proj"
    [ -n "$oper" ] && swit="oper"

    swit_equal=
    [ "$act_type" = "$swit" ] && swit_equal=1
    [ -n "$swit" ] && act_type="$swit"

    # echo "+++++++++++ swit=${swit}      act_type=${act_type}"

    if [ -z "$act_type" ] || [ -n "$swit_equal" ] || [ -z "$projs" ] || [ -z "$opers" ]; then
      projs="$(echo "${projs} ${proj}" | xargs)"
      opers="$(echo "${opers} ${oper}" | xargs)"
      continue
    fi

    for o in $opers; do
      for p in $projs; do
        items="${items} ${o} ${p}"
      done
    done

    # echo ">>>>> projs=${projs}     opers=${opers}"

    projs="$proj"
    opers="$oper"
  done

  [ -n "$proj_for_logs" ] && [ -n "$on_logs" ] && items="${items} LOGS ${proj_for_logs}"

  ARGUMENTS=$items
}

func_analysis_arguments $@ || exit

# $1 - OPERATION
# $2 - PROJECT
func_exe() {

  echo "__ func_exe \$1=$1 \$2=$2"
  # return 0

  case "$1" in
    "LOGS") docker compose -p "$2" logs -f ;;
    "DOWN") docker compose -p "$2" down;;

    "CLEAN") ;;

    "UP")
      func_create_networks

      set -o allexport
      . "${__INFRA_LOCAL__}/services.env" || exit 1
      set +o allexport

      export UID=$(id -u)
      export GID=$(id -g)

      case "$2" in
        "$CONST_PROJ_HOME_CORE")
          docker compose -p "$CONST_PROJ_HOME_CORE" --project-directory "$ROOT" \
            -f "${ROOT}/home-services.yaml" \
            --parallel=2 up --quiet-pull --detach
        ;;

        "$CONST_PROJ_HOME_GITLAB")
          docker compose -p "$CONST_PROJ_HOME_GITLAB" --project-directory "$ROOT" \
            -f "${ROOT}/service-gitlab.yaml" \
            --parallel=2 up --quiet-pull --detach
        ;;

        "$CONST_PROJ_HOME_NEXTCLOUD")
          docker compose -p "$CONST_PROJ_HOME_NEXTCLOUD" --project-directory "$ROOT" \
            -f "${ROOT}/service-nextcloud.yaml" \
            --parallel=3 up --quiet-pull --detach
        ;;
      esac
    ;;
  esac
}

for ARG in $ARGUMENTS; do
  case "$ARG" in
    "curl")
      docker run -it --rm --network net-home --network net-gitlab --network net-nextcloud curlimages/curl:8.10.1 sh
      ;;

    # "clean")
    #   docker system prune -f
    #   for id in $(docker volume ls --filter name="home" -q); do
    #     docker volume rm "$id"
    #   done
    #   ;;

    "UP" | "DOWN" | "LOGS") OPERATION="$ARG"; continue ;;
    *) PROJECT="$ARG" ;;
  esac

  # ---
  if [ -n "$PROJECT" ] && [ -n "$OPERATION" ]; then
    func_exe "$OPERATION" "$PROJECT"

    OPERATION=
    PROJECT=
  fi
done
