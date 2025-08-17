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

[ ! -d "$__INFRA_LOCAL__" ] && mkdir "$__INFRA_LOCAL__"
chmod -R 0700 "$__INFRA_LOCAL__"

BRANCH=$(git -C "$__INFRA_REPO__" rev-parse --abbrev-ref HEAD) || exit
git -C "$__INFRA_REPO__" pull origin "$BRANCH" || exit

echo "$NOW" >"$LAST_UPDATE_FILE" || exit
