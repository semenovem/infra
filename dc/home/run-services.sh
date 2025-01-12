#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
OPERATION=
PROJECT=
CONST_PROJ_HOME_CORE="home"
CONST_PROJ_HOME_GITLAB="home-gitlab"


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

      "core")                proj="$CONST_PROJ_HOME_CORE" ;;
      "gitlab")              proj="$CONST_PROJ_HOME_GITLAB" ;;
      "nextcloud" | "cloud") proj="nextcloud" ;;

      "eof_arg") ;;
      "clean" | "curl") items="${arg} ${items}"; continue ;;
      *)
        echo "[ERRO] unknown [$ARG] - allow [up|down|clean|logs|curl|gitlab|nextcloud]"
        exit
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

  echo $items
}

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
        "$CONST_PROJ_HOME_GITLAB")
          docker compose -p "$CONST_PROJ_HOME_GITLAB" --project-directory "$ROOT" \
            -f "${ROOT}/service-gitlab.yaml" \
            --parallel=2 \
            up --quiet-pull --detach
        ;;

        "$CONST_PROJ_HOME_CORE")
          docker compose -p "$CONST_PROJ_HOME_CORE" --project-directory "$ROOT" \
            -f "${ROOT}/home-services.yaml" \
            --parallel=2 \
            up --quiet-pull --detach
        ;;
      esac
    ;;
  esac
}


# analysis of arguments
for ARG in $(func_analysis_arguments $@); do

  echo ">>>>>> arg=$ARG"

  case "$ARG" in
    "curl")
      docker run -it --rm --network net-home --network net-gitlab curlimages/curl:8.10.1 sh
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
