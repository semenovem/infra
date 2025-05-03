#!/bin/sh

# $1 - message

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../.local/services.env" || exit 1

[ -z "$1" ] && echo "[ERRO] empty message in \$1" >&2 && exit 1
[ -z "$BOT_API_EVGIO_CHAT_ID" ] && echo "[ERRO] empty BOT_API_EVGIO_CHAT_ID" >&2 && exit 1
[ -z "$BOT_API_EVGIO_TOKEN" ] && echo "[ERRO] empty BOT_API_EVGIO_TOKEN" >&2 && exit 1

# curl -s "https://api.telegram.org/bot${BOT_API_EVGIO_TOKEN}/getUpdates"

curl -s -X POST "https://api.telegram.org/bot${BOT_API_EVGIO_TOKEN}/sendMessage" \
  -d "chat_id=${BOT_API_EVGIO_CHAT_ID}&text=${1}"
