#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

cd "$ROOT" || exit 1

VERSION="1.0.0"

#export GOOS=linux
#export GOARCH=amd64

go build -ldflags="-X 'main.appVersion=${VERSION}'" \
  -o "${ROOT}/bin/configuration-app"
