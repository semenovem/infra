#!/bin/bash

# optional: $1 - new role of conservation

# name of roles
# HOME_SERVER
# STANDBY_SERVER
# PROXY_SERVER
# WORKSTATION
# MINI_SERVER
# OFFICE_SERVER

[ -z "$__INFRA_LOCAL__" ] && >&2 echo "not set [__INFRA_LOCAL__]" && exit 1

ROLE_FILE="${__INFRA_LOCAL__}/role"

if [ -z "$1" ]; then
  if [ -f "$ROLE_FILE" ]; then
    cat "$ROLE_FILE" || exit

    exit 0
  fi

  echo "NOT_DEFINED"
fi

echo "$1" >"$ROLE_FILE"
