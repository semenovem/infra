#!/bin/bash

#************************************************************
# ssh-congig.sh [-workstation | -server] [-yes] -file ....
#************************************************************

__BIN__=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")

__CFG_WORKSTATION__="${__BIN__}/../home/ssh/workstation.txt"
__CFG_SERVER__="${__BIN__}/../home/ssh/server.txt"

__CONST_WORKSTATION__="-workstation"
__CONST_SERVER__="-server"
__CONST_FILE__="-file"
__CONST_YES__="-yes"

__ARG_FILE_ON__=
__ARG_FILE__=
__ARG_YES__=
__SSH_CONFIG__=
__ERR__=

function help {
  echo "use: ${__CONST_WORKSTATION__} | ${__CONST_SERVER__}" \
    "[${__CONST_YES__} ${__CONST_FILE__} path to file]"
}

function err {
  __ERR__=1
  echo "[ERR][ssh-config] $*" >&2
}

function checkFileExist {
  local f ret=0
  for f in $@; do
    [ ! -f "$f" ] && ret=1 && err "file not exist '${f}'"
  done
  return "$ret"
}

# parse arguments
function parseArgs {
  local p prev
  for p in "$@"; do
    arg=1
    case $p in
    "$__CONST_YES__") __ARG_YES__=1 ;;
    "$__CONST_WORKSTATION__")
      __SSH_CONFIG__+=$(cat "$__CFG_WORKSTATION__")
      __SSH_CONFIG__+="\n\n\n"
      __SSH_CONFIG__+=$(cat "$__CFG_SERVER__")
      ;;
    "$__CONST_SERVER__")
      __SSH_CONFIG__=$(cat "$__CFG_SERVER__")
      ;;
    "$__CONST_FILE__")
      __ARG_FILE_ON__=1
      prev="$p"
      ;;
    *)
      arg=
      if [ -z "$prev" ]; then
        err "unknown argument: '$p'"
        continue
      fi
      ;;
    esac

    [ -n "$arg" ] && continue
    [ "$prev" = "$p" ] && continue

    if [ "$prev" ]; then
      case $prev in
      "$__CONST_FILE__") __ARG_FILE__="$p" ;;
      *) err "value not processed: ${prev} ${p}" ;;
      esac

      prev=
    fi
  done
}

checkFileExist "$__CFG_WORKSTATION__" "$__CFG_SERVER__" || exit 1
parseArgs $@

[ -z "$__SSH_CONFIG__" ] && err "not passed type of ssh-config"

[ -n "$__ARG_FILE_ON__" ] && [ -z "$__ARG_FILE__" ] &&
  err "not processed file name for ${__CONST_FILE__}"

[ -n "$__ERR__" ] && help && exit 1

# save to file
if [ -n "$__ARG_FILE__" ]; then
  if [ -s "$__ARG_FILE__" ] && [ -z "$__ARG_YES__" ]; then
    read -rp "File '${__ARG_FILE__}' is not empty, replace [y/N] ?: " ans
    case "$ans" in
    "y" | "Y") ;;
    *) echo "cancel action" && exit 0 ;;
    esac
  fi

  echo -e "$__SSH_CONFIG__" >"$__ARG_FILE__" || exit 1
  exit 0
fi

echo -e "$__SSH_CONFIG__"
