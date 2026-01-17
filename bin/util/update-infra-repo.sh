#!/bin/env bash

# optional: $1 = force

set -eu
FORCE="${1:-}"
[ ! -d "$__INFRA_LOCAL__" ] && mkdir "$__INFRA_LOCAL__" && chmod -R 0700 "$__INFRA_LOCAL__"

git -C "$__INFRA_REPO__" diff-index --quiet HEAD -- || (echo "[WARN][$0] have unstaged changes" >&2; exit 1)
BRANCH=$(git -C "$__INFRA_REPO__" rev-parse --abbrev-ref HEAD)
[ "$BRANCH" != 'master' ] && echo "[WARN][$0] branch must be main" >&2 && exit 1

LAST_UPDATE_FILE="${__INFRA_LOCAL__}/last-update-repo"
[ -f "$LAST_UPDATE_FILE" ] && PREV=$(cat "$LAST_UPDATE_FILE")

[[ "$PREV" =~ ^[0-9]+$ ]] || PREV=0

NOW=$(date "+%Y%m%d")
[ "$((NOW - PREV))" -eq 0 ] && [ "$FORCE" != 'force' ] && exit 0

git -C "$__INFRA_REPO__" pull origin -q "$BRANCH"
echo "$NOW" >"$LAST_UPDATE_FILE"

echo "[INFO][$0] repo updated"

# --- move infra bin files to /usr/local/bin

sudo rsync --owner --group --inplace --quiet --chmod=+rx \
  "${__INFRA_REPO__}/bin/common/"{count-objects,li} \
  "/usr/local/bin"
