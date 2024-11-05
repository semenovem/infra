#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

if [ -n "$1" ]; then
  while true; do
    sh "${ROOT}/run.sh"
    sleep 1
  done
else
  go run "${ROOT}/"*.go
fi
