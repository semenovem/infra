#!/bin/bash

# $1 callable file

[ -z "$1" ] && echo "[ERRO] empty \$1" >&2 && exit 1

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
callable_file_name="$1"
shift


case "$callable_file_name" in
  "scr-bot-evgio") sh "${ROOT}/bin/util/bot-evgio.sh" "$@" ;;

*)
  echo "[ERRO] not found [${1}]" >&2
  exit 1
  ;;
esac
