#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_lib/core.sh" || exit 1

EXCLUDE="install-local help utils"

pipe() {
  while read -r data; do
    basename "$data"
  done
}

short() {
  [ -n "$__SHORT__" ] && echo "-- help: "
}

echo "$(short)[li cert scanLocalNet temp envi-utils !]"

echo ""
echo "sudo netstat -lntup  # список приложений, использующих порты"
