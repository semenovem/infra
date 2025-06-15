#!/bin/bash

# optional: $1 = force

LAST_UPDATE_FILE="${__INFRA_LOCAL__}/last-update-repo"
if [ -f "$LAST_UPDATE_FILE" ]; then
  PREV=$(cat "$LAST_UPDATE_FILE") || exit 1
fi

[ -z "$PREV" ] && PREV=0

NOW=$(date "+%Y%m%d") || exit 1
DIFF=$((NOW - PREV))
[ "$DIFF" -eq 0 ] && [ "$1" != 'force' ] && exit 0

if ! cd "$__INFRA_REPO__"; then
  >&2 echo "[ERRO][$0] cd to [${__INFRA_REPO__}]"
  exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD) || exit
git pull origin "$BRANCH" || exit

echo "$NOW" >"$LAST_UPDATE_FILE" || exit
