#!/bin/sh

# Работа с конфигурацией
# $1 - операция

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_lib/core.sh" || exit 1

OPER=$1
ROLE=$2

filter_by_role() {
  echo "$2" | grep -iq "$ROLE" && echo "$1"
}

case "$OPER" in

# получить список машин по роли
"get-cpis-by-role")
  __config__ "filter_by_role" "cpi" "roles"
  ;;

*)
  __err__ "Передана незвестная команда [$OPER]"
  exit 1
  ;;
esac
