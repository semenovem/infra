#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
[ -d "$1" ] && ROOT=$1
. "${ROOT}/../_lib/core.sh" || exit 1

cd "$ROOT" || exit 1

NOW=$(date "+%Y%m%d") || exit 1

if [ -f "$__CORE_TIME_REPO_LAST_UPDATED__" ]; then
  PREV=$(cat "$__CORE_TIME_REPO_LAST_UPDATED__") || exit 1
fi

[ -z "$PREV" ] && PREV=0

DIFF=$((NOW - PREV))
[ "$DIFF" -eq 0 ] && [ -z "$__FORCE__" ] && exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD) || exit 1
git pull origin "$BRANCH" || exit 1

echo "$NOW" >"$__CORE_TIME_REPO_LAST_UPDATED__" || exit 1
