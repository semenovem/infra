#!/bin/sh

# Обновление всех git репозиториев
_NC_='\033[0m'
_BACKGROUND_DARK_BLUE_='\033[44m'

CURRENT_DIR=$1
[ -z "$CURRENT_DIR" ] && CURRENT_DIR="$PWD"

# this is git repo
if [ -d "${CURRENT_DIR}/.git" ]; then
  NOT_CLEAR=
  SUCCESS_PULL="\e[1;31mERRO\e[m"
  git -C "$CURRENT_DIR" diff --exit-code 1>/dev/null &&
  git -C "$CURRENT_DIR" diff --cached --exit-code  1>/dev/null || NOT_CLEAR=1

  BRANCH=$(git -C "$CURRENT_DIR" rev-parse --abbrev-ref HEAD) || exit

  PRE_DIR="$(dirname "$CURRENT_DIR")"
  PRE_PRE_DIR="$(dirname "$PRE_DIR")"
  SHOW_DIR="$(basename "$PRE_PRE_DIR")/$(basename "$PRE_DIR")/$(basename "$CURRENT_DIR")"

  [ -z "$NOT_CLEAR" ] && git -C "$CURRENT_DIR" pull origin --no-rebase --no-commit -q
  [ "$?" -eq 0 ] && SUCCESS_PULL="\e[1;32mINFO\e[m"

  printf "[$SUCCESS_PULL] %-50s  " "$SHOW_DIR"

  [ -n "$NOT_CLEAR" ] && NOT_CLEAR="not clear"
  echo "[${_BACKGROUND_DARK_BLUE_}${BRANCH}${_NC_}] ${NOT_CLEAR}"

  exit 0
fi

# iterate dirs

for DIR in "${CURRENT_DIR}"/*; do
  [ ! -d "$DIR" ] && continue
  sh "$0" "$DIR"
done
