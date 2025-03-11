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
export __INFRA_BIN__="${__INFRA_REPO__}/bin"

# -------------------------------------------------------------------
# repo
[ -z "$__INFRA_REPO__" ] && >&2 echo "[ERRO][$0] variable [__INFRA_REPO__] not set" && return

[ ! -d "$__INFRA_REPO__" ] && \
  >&2 echo "[ERRO][$0] variable [__INFRA_REPO__] contains not exist directory [${__INFRA_REPO__}]" && \
  return

[ -z "$__INFRA_BIN__" ] && >&2 echo "[ERRO][$0] variable [__INFRA_BIN__] not set" && return

export PATH="${PATH}:${__INFRA_BIN__}"

self_updater_script="${__INFRA_BIN__}/util/self/update-repo.sh"
if [ -f "$self_updater_script" ]; then
  sh "$self_updater_script" "update-repo" || >&2 echo "[ERRO][$0] execute 'update-repo'"
fi

# platform actions
case "$(uname)" in
  'Linux') ;;

  'Darwin')
    f="${__INFRA_REPO__}/profiles/macos.sh"
    # shellcheck disable=SC1090
    . "$f" || >&2 echo "[ERRO][$0] source file $f"

    export PATH="${PATH}:${__INFRA_BIN__}/macos"
   ;;
*) ;;
esac

# -------------------------------------------------------------------
role="ROLE_$(cat "${__INFRA_LOCAL__}/role")" || >&2 echo "[ERRO][$0] execute 'machine-role.sh'"

case "$role" in
  "ROLE_HOME_SERVER")
    export PATH="${PATH}:${__INFRA_BIN__}/linux"
  ;;
  "ROLE_STANDBY_SERVER")
    export PATH="${PATH}:${__INFRA_BIN__}/linux"
  ;;
  "ROLE_PROXY_SERVER");;
  "ROLE_WORKSTATION");;
  "ROLE_MINI_SERVER")
    export PATH="${PATH}:${__INFRA_BIN__}/linux"
  ;;
  "ROLE_OFFICE_SERVER")
    export PATH="${PATH}:${__INFRA_BIN__}/linux"
  ;;
esac
