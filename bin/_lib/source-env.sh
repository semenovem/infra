#!/bin/sh

FILE="${__INFRA_REPO__}/configs/self.env"

set -o allexport
# shellcheck disable=SC1090
. "$FILE"
[ "$?" -ne 0 ] && echo "[ERRO][$0] source file [${FILE}]" && exit 1
set +o allexport

[ -z "$__INFRA_LOCAL__" ] && echo "[ERRO][$0] empty variable '__INFRA_LOCAL__'" && exit 1

if [ ! -d "$__INFRA_LOCAL__" ]; then
  mkdir -p "$__INFRA_LOCAL__" || exit
  chmod 0600 "$__INFRA_LOCAL__" || exit
fi

# Machine role file
export __SELF_PATH_TO_MACHINE_ROLE_FILE__="${__INFRA_LOCAL__}/${__SELF_RELATIVE_PATH_TO_MACHINE_ROLE_FILE__}"

# Date of last repository update
export __SELF_PATH_TO_LAST_UPDATE_REPO_FILE__="${__INFRA_LOCAL__}/${__SELF_RELATIVE_PATH_TO_LAST_UPDATE_REPO_FILE__}"
