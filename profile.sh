#!/bin/bash

__VERSION__="1.0"
__LOGS_DIR__="${HOME}/_logs"
__ERR_FILE__="${__LOGS_DIR__}/environment-errs.log"
__SYNC_FILE="${__LOGS_DIR__}/env_sync_file.txt"

__OS__=$1
__DIR__=$2

# define OS
__SELF_OS_IS_UNIX__=
__SELF_OS_IS_LINUX__=
__SELF_OS_IS_FEDORA__=
__SELF_OS_IS_DEBIAN__=
__SELF_OS_IS_RASPBIAN__=

OS_RELEASE="/etc/os-release"
if [ -f "$OS_RELEASE" ]; then
  __SELF_OS_IS_LINUX__=1
  grep -iE "^ID_LIKE=debian" "$OS_RELEASE" -q && __SELF_OS_IS_DEBIAN__=1
  grep -iE "^ID=raspbian" "$OS_RELEASE" -q && __SELF_OS_IS_RASPBIAN__=1
  grep -iE "^ID_LIKE=" "$OS_RELEASE" | grep -i -q "fedora" && __SELF_OS_IS_FEDORA__=1
else
  __SELF_OS_IS_UNIX__=1
fi
unset OS_RELEASE

function __err__ {
  echo -e "[ERROR] [$(date)] $@" >>"$__ERR_FILE__"
}

function __resource__ {
  local file dir=$1
  [ -z "$dir" ] && __err__ "no argument passed. must be name of directory"
  [ ! -d "$dir" ] && __err__ "directory '${dir}' does not exist"
  for file in "${dir:?}"/*.sh; do
    source "$file"
  done
}

###################################################
# creating a directory for logs
if [ ! -d "$__LOGS_DIR__" ]; then
  mkdir "$__LOGS_DIR__" || return 1
fi

# update repo
bash "${__DIR__}/_self/update-repo.sh" \
  -sync-file "$__SYNC_FILE" \
  2>>"$__ERR_FILE__" ||
  __err__ "__upd_environment_repo__"

# #################################################
# apply resources

__resource__ "${__DIR__:?}/home/common"

case "$__OS__" in
"-macos") __resource__ "${__DIR__:?}/home/macos" ;;
"-linux") __resource__ "${__DIR__:?}/home/linux" ;;
"") echo "requare to set arg (OS name) \$1" ;;
*) echo "unknown arg (OS name)) \$1'${__OS__}'" ;;
esac

# TODO - make a comparison on the added functions and show them, so as not to write by hand
function help {
  echo "ver:${__VERSION__} [help, cert, myip, scanLocalNet, temp]"
  if [ $1 ]; then
    echo "> log directory    = ${__LOGS_DIR__}"
    echo "> log error file   = ${__ERR_FILE__}"
    echo "> sunc file        = ${__SYNC_FILE}"
  fi
}

help

unset __OS__ __DIR__
unset -f __resource__ __err__
