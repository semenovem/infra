#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
ARGUMENTS=

CONST_PROJ_CORE="home"
CONST_PROJ_LOGGING="home-logging"
CONST_PROJ_MONITORING="home-monitoring"
CONST_PROJ_GITLAB="home-gitlab"
CONST_PROJ_NEXTCLOUD="home-nextcloud"

CONST_PROJ_YA_DISK="home-ya-disk" ## TODO
CONST_PROJ_MINIDLNA="home-minidlna" ## TODO

ALL_PROJS="${CONST_PROJ_CORE} ${CONST_PROJ_LOGGING} ${CONST_PROJ_MONITORING} ${CONST_PROJ_NEXTCLOUD} ${CONST_PROJ_GITLAB} "


func_help() {
  echo "allow commands: [up|down|clean|logs|curl] projects: [all|core|gitlab|nextcloud|monitoring|logging|minidlna]"
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
  all_selected=

  for arg in "$@"; do
    oper=
    proj=

    case "$arg" in
      "up")   oper="UP"   ;;
      "down") oper="DOWN" ;;
      "logs") on_logs=1; continue ;;

      "core")       proj="$CONST_PROJ_CORE" ;;
      "gitlab")     proj="$CONST_PROJ_GITLAB" ;;
      "nextcloud")  proj="$CONST_PROJ_NEXTCLOUD" ;;
      "monitoring") proj="$CONST_PROJ_MONITORING" ;;
      "logging")    proj="$CONST_PROJ_LOGGING" ;;
      "all")        all_selected=1; proj="ALL" ;;

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

  [ -n "$proj_for_logs" ] && [ -n "$on_logs" ] && [ -z "$all_selected" ] && items="${items} LOGS ${proj_for_logs}"

  ARGUMENTS=$items
}

func_analysis_arguments $@ || exit

# $1 - OPERATION
# $2 - PROJECT
func_exe() {

  # echo "__ func_exe \$1=$1 \$2=$2"
  # return 0

  case "$1" in
    "LOGS") docker compose -p "$2" logs -f ;;
    "DOWN") docker compose -p "$2" down ;;

    "CLEAN") ;;

    "UP")
      func_create_networks

      set -o allexport
      . "${__INFRA_LOCAL__}/services.env" || exit 1
      set +o allexport

      export UID=$(id -u)
      export GID=$(id -g)

      case "$2" in
        "$CONST_PROJ_CORE")
          docker compose -p "$CONST_PROJ_CORE" --project-directory "$ROOT" \
            -f "${ROOT}/service-core.yaml" \
            --parallel=2 up --quiet-pull --detach
        ;;

        "$CONST_PROJ_GITLAB")
          docker compose -p "$CONST_PROJ_GITLAB" --project-directory "$ROOT" \
            -f "${ROOT}/service-gitlab.yaml" \
            --parallel=2 up --quiet-pull --detach
        ;;

        "$CONST_PROJ_NEXTCLOUD")
          docker compose -p "$CONST_PROJ_NEXTCLOUD" --project-directory "$ROOT" \
            -f "${ROOT}/service-nextcloud.yaml" \
            --parallel=3 up --quiet-pull --detach
        ;;

        "$CONST_PROJ_MONITORING")
          docker compose -p "$CONST_PROJ_MONITORING" --project-directory "$ROOT" \
            -f "${ROOT}/service-monitoring.yaml" \
            --parallel=3 up --quiet-pull --detach
        ;;

        "$CONST_PROJ_LOGGING")
          docker compose -p "$CONST_PROJ_LOGGING" --project-directory "$ROOT" \
            -f "${ROOT}/service-logging.yaml" \
            --parallel=3 up --quiet-pull --detach
        ;;
      esac
    ;;
  esac
}

# $1 - operatoon [UP|DOWN]
# $2... - name of services
func_all() {
  o="$1"
  shift
  for proj in $@; do
    func_exe "$o" "$proj"
  done
  return 0
}


OPERATION=
PROJECT=

for ARG in $ARGUMENTS; do
  case "$ARG" in
    "curl")
      docker run -it --rm \
        --network net-home --network net-gitlab --network net-nextcloud \
        --network net-monitoring \
        --network net-prometheus \
        --network net-logging \
        curlimages/curl:8.10.1 sh
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
    if [ "$PROJECT" = "ALL" ]; then
      [ "$OPERATION" = "UP" ] && func_all "UP" $ALL_PROJS
      [ "$OPERATION" = "DOWN" ] && \
        func_all "DOWN" $(echo "$ALL_PROJS" | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }')

      continue
    fi

    func_exe "$OPERATION" "$PROJECT"

    OPERATION=
    PROJECT=
  fi
done
