#!/usr/bin/env bash

THIS="${BASH_SOURCE[0]}"
[ -z "$THIS" ] && THIS="$0"

alias ll='ls -lh'
alias la='ls -la'

if which minikube >/dev/null 2>&1 && ! which kubectl >/dev/null 2>&1; then
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

# --- environment
export __INFRA_REPO__="${HOME}/_infra"
export __INFRA_LOCAL__="${__INFRA_REPO__}/.local"

[ -z "$__INFRA_REPO__" ] && echo "[ERRO][$THIS] var __INFRA_REPO__ not set" >&2 && return
[ ! -d "$__INFRA_REPO__" ] && echo "[ERRO][$THIS] var __INFRA_REPO__ must be a directory [${__INFRA_REPO__}]" >&2 && return

export PATH="${PATH}:${__INFRA_REPO__}/bin/common:${__INFRA_REPO__}/bin"

# --- update infra

bash "${__INFRA_REPO__}/bin/util/update-infra-repo.sh" || :

# --- platform actions
PLATFORM_NAME="${__INFRA_REPO__}/bin/util/platform.sh"

case "$(sh "$PLATFORM_NAME")" in
  "PLATFORM_MACOS_"*)
  export PATH="${PATH}:${__INFRA_REPO__}/bin/macos"
  ;;

  "LINUX");;
esac

# machine role actions -------------------------------
ROLE="$(sh "${__INFRA_REPO__}/bin/util/machine-role.sh")" || >&2 echo "[ERRO][$0] execute 'machine-role.sh'"

case "$ROLE" in
  "HOME_SERVER")
    export PATH="${PATH}:${__INFRA_REPO__}/bin/roles/home_server"
  ;;
  "STANDBY_SERVER")
  ;;
  "PROXY_SERVER");;
  "WORKSTATION");;
  "MINI_SERVER")
#    export PATH="${PATH}:${__INFRA_REPO__}/bin/linux"
  ;;
  "OFFICE_SERVER")
  ;;
esac
