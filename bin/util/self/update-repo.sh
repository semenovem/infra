#!/bin/sh

# $1 - name of task
# $2=1 - for force update

. "${__INFRA_REPO__}/bin/_lib/source-env.sh" || exit


if [ -f "$__SELF_PATH_TO_LAST_UPDATE_REPO_FILE__" ]; then
  PREV=$(cat "$__SELF_PATH_TO_LAST_UPDATE_REPO_FILE__") || exit 1
fi

case "$1" in
  "get-last-update")
    echo "$PREV"
    exit
  ;;

  "update-repo")
    mkdir -p "$(dirname "$__SELF_PATH_TO_LAST_UPDATE_REPO_FILE__")" || exit

    NOW=$(date "+%Y%m%d") || exit

    [ -z "$PREV" ] && PREV=0

    DIFF=$((NOW - PREV))
    [ "$DIFF" -eq 0 ] && [ -z "$2" ] && exit 0

    cd "$__INFRA_REPO__" || exit

    BRANCH=$(git rev-parse --abbrev-ref HEAD) || exit
    [ "$BRANCH" != "master" ] && exit 0
    git pull origin "$BRANCH" || exit

    echo "$NOW" >"$__SELF_PATH_TO_LAST_UPDATE_REPO_FILE__" || exit

    exit
  ;;

  *) echo "[ERRO][$0] unknown arg \$1"
esac
