#!/bin/bash

BIN=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")

CONST_FILE_SYNC_ARG="-sync-file"

ARG_FILE_SYNC_ON=
ARG_FILE_SYNC=

ERR=
NOW=
PREV=
DIFF=
BRANCH=

# parse arguments
for p in "$@"; do
  case $p in
  "$CONST_FILE_SYNC_ARG")
    PREV="$p"
    ARG_FILE_SYNC_ON=true
    ;;
  *)
    if [ -z "$PREV" ]; then
      ERR=1
      echo "Не известный аргумент:$p" >&2
      continue
    fi
    ;;
  esac

  [ "$PREV" = "$p" ] && continue

  if [ "$PREV" ]; then
    case $PREV in
    "$CONST_FILE_SYNC_ARG") ARG_FILE_SYNC="$p" ;;
    *)
      ERR=1
      echo "[ERR] value not processed: ${PREV} ${p}" >&2
      ;;
    esac

    PREV=
  fi
done

[ -n "$ERR" ] && exit 1

if [ -n "$ARG_FILE_SYNC_ON" ]; then
  NOW=$(date "+%Y%m%d") || exit 1
  [ -f "$ARG_FILE_SYNC" ] && PREV=$(cat "$ARG_FILE_SYNC")
  [ -z "$PREV" ] && PREV=0
  let DIFF="$NOW"-"$PREV"
  [ "$DIFF" -eq 0 ] && exit 0
fi

cd "${BIN}/.." || exit 1

# git operation
BRANCH=$(git rev-parse --abbrev-ref HEAD) || exit 1
git pull origin "$BRANCH"

if [ $? -eq 0 ] && [ -n "$ARG_FILE_SYNC_ON" ]; then
  echo "$NOW" >"$ARG_FILE_SYNC"
fi
