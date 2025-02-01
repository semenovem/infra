#!/bin/sh

# $1 - name of task
# $1=set-machine-role then $2 - name of machine role if

. "${__INFRA_REPO__}/bin/_lib/source-env.sh" || exit

case "$1" in
  "get-machine-role")
    if [ -f "$__SELF_PATH_TO_MACHINE_ROLE_FILE__" ]; then
      cat "$__SELF_PATH_TO_MACHINE_ROLE_FILE__"
      exit
    fi
  ;;

  "set-machine-role")
    mkdir -p "$(dirname "$__SELF_PATH_TO_MACHINE_ROLE_FILE__")" || exit
    [ -z "$2" ] && >&2 echo "[ERRO][$0] empty \$2 - must be name of machine role" && exit 1
    echo "$2" > "$__SELF_PATH_TO_MACHINE_ROLE_FILE__"
    exit
  ;;

  *) >&2 echo "[ERRO][$0] unknown arg \$1"; exit 1;;
esac
