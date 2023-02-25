#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

cd "$ROOT" || exit 1

#go build -o configuration-x86 \
#  -ldflags="-X 'main.appVersion=1.0.0'" \
#  *.go

VERSION="1.0.0"

export GOOS=linux
export GOARCH=amd64
go build -ldflags="-X 'main.appVersion=${VERSION}'" \
  -o "${ROOT}/../../bin/platforms/linux-amd64/configuration-envi"

export GOOS=linux
export GOARCH=arm
go build -ldflags="-X 'main.appVersion=${VERSION}'" \
  -o "${ROOT}/../../bin/platforms/linux-arm/configuration-envi"

export GOOS=darwin
export GOARCH=amd64
go build -ldflags="-X 'main.appVersion=${VERSION}'" \
  -o "${ROOT}/../../bin/platforms/darwin-amd64/configurator-envi"
