#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

cd "$ROOT" || exit 1

VERSION="1.2.0"

FILE=$1

echo "[INFO] file=${FILE}"

[ -z "$FILE" ] && FILE="${ROOT}/bin/configuration-app"

#export GOOS=linux
#export GOARCH=amd64

go build -ldflags="-X 'main.appVersion=${VERSION}'" \
  -o "$FILE"
