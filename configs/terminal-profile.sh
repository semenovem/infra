#!/bin/sh

alias ll='ls -l'
alias la='ls -la'

# Directory size
# du -xhd 1 . 2> /dev/null | sort -rh
li() {
  [ -n "$1" ] && dir="$1" || dir="."
  du -xhd 1 "$dir" 2> /dev/null | sort -rh
}

# -------------------------------------------------------------------
export __INFRA_REPO__="${HOME}/_infra"
export __INFRA_LOCAL__="${__INFRA_REPO__}/.local"

# Deprecated
export __INFRA_BIN__="${__INFRA_REPO__}/bin"


# -------------------------------------------------------------------
# repo
[ -z "$__INFRA_REPO__" ] && >&2 echo "[ERRO][$0] variable [__INFRA_REPO__] not set" && return

[ ! -d "$__INFRA_REPO__" ] && \
  >&2 echo "[ERRO][$0] variable [__INFRA_REPO__] contains not exist directory [${__INFRA_REPO__}]" && \
  return

export PATH="${PATH}:${__INFRA_REPO__}/bin"

sh "${__INFRA_REPO__}/bin/util/self/update-repo.sh" "update-repo" \
  || >&2 echo "[ERRO][$0] execute 'update-repo'"


# -------------------------------------------------------------------
# platform actions
. "${__INFRA_REPO__}/bin/_lib/func.sh" || return
case "$(__lib_platform__)" in
  "MACOS")
  export PATH="${PATH}:${__INFRA_REPO__}/bin/macos"
  ;;

  "LINUX");;
esac

# -------------------------------------------------------------------
# machine role actions
ROLE=$(sh "${__INFRA_REPO__}/bin/util/self/machine-role.sh" "get-machine-role") || >&2 echo "[ERRO][$0] execute 'machine-role.sh'"

case "$ROLE" in
  "HOME_SERVER")
    export PATH="${PATH}:${__INFRA_REPO__}/bin/linux"
  ;;
  "STANDBY_SERVER")
    export PATH="${PATH}:${__INFRA_REPO__}/bin/linux"
  ;;
  "PROXY_SERVER");;
  "WORKSTATION");;
  "MINI_SERVER")
    export PATH="${PATH}:${__INFRA_REPO__}/bin/linux"
  ;;
  "OFFICE_SERVER")
    export PATH="${PATH}:${__INFRA_REPO__}/bin/linux"
  ;;
esac
