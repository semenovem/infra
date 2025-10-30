#!/bin/bash

# $1 - message

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../.local/services.env" || exit 1

[ -z "$1" ] && echo "[ERRO] empty message in \$1" >&2 && exit 1
[ -z "$__BOT_API_EVGIO_CHAT_ID__" ] && echo "[ERRO] empty __BOT_API_EVGIO_CHAT_ID__" >&2 && exit 1
[ -z "$__BOT_API_EVGIO_TOKEN__" ] && echo "[ERRO] empty __BOT_API_EVGIO_TOKEN__" >&2 && exit 1

# curl -s "https://api.telegram.org/bot${__BOT_API_EVGIO_TOKEN__}/getUpdates"

curl -s -X POST "https://api.telegram.org/bot${__BOT_API_EVGIO_TOKEN__}/sendMessage" \
  -d "chat_id=${__BOT_API_EVGIO_CHAT_ID__}&text=${1}"
