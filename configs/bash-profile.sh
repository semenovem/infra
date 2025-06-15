#!/bin/bash

alias ll='ls -l'
alias la='ls -la'

if which minikube 1>/dev/null && ! which kubectl; then
  alias kubectl="minikube kubectl --"
fi

# Directory size
# du -xhd 1 . 2> /dev/null | sort -rh
li() {
  du -xhd 1 "${1-.}" 2> /dev/null | sort -rh
}

#goland() {
#  open -na "GoLand.app" --args "$@"
#}

# -------------------------------------------------------------
export __INFRA_REPO__="${HOME}/_infra"
export __INFRA_LOCAL__="${__INFRA_REPO__}/.local"

# Deprecated
export __INFRA_BIN__="${__INFRA_REPO__}/bin"

#env | grep INFRA | sort


# environment -------------------------------------------------
[ -z "$__INFRA_REPO__" ] && \
  >&2 echo "[ERRO][$0] variable [__INFRA_REPO__] not set" && \
  return

[ ! -d "$__INFRA_REPO__" ] && \
  >&2 echo "[ERRO][$0] variable [__INFRA_REPO__] contains not exist directory [${__INFRA_REPO__}]" && \
  return

export PATH="${PATH}:${__INFRA_REPO__}/bin/common:${__INFRA_REPO__}/bin"

sh "${__INFRA_REPO__}/bin/util/update-infra-repo.sh" || \
  >&2 echo "[ERRO][$0] execute 'update-repo'"

# platform actions --------------------------------------------
PLATFORM_NAME="${__INFRA_REPO__}/bin/util/platform.sh"
case "$PLATFORM_NAME" in
  "MACOS")
  export PATH="${PATH}:${__INFRA_REPO__}/bin/macos"
  ;;

  "LINUX");;
esac

return 0

# machine role actions -------------------------------
ROLE=$(sh "${__INFRA_REPO_ _}/bin/util/self/machine-role.sh" "get-machine-role") || >&2 echo "[ERRO][$0] execute 'machine-role.sh'"

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
