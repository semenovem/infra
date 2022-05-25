#!/bin/bash

#************************************************************
# add authorized keys to user
# ssh-authorized-keys.sh [-all | -server | -workstation]
#   [-replace] [-yes] -file ....
#************************************************************

__BIN__=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")

__KEYS_FILE__="${__BIN__}/../home/ssh/keys-pub.txt"

__CONST_ALL__="-all"
__CONST_SERVER__="-server"
__CONST_WORKSTATION__="-workstation"
__CONST_FILE__="-file"
__CONST_YES__="-yes"
__CONST_REPLACE__="-replace"

__ARG_FILE_ON__=
__ARG_FILE__=
__ARG_YES__=
__ARG_REPLACE__=
__AUTHORIZED_KEYS__=
__ERR__=

REC=

function help {
  echo "use: [${__CONST_ALL__} | ${__CONST_SERVER__} | ${__CONST_WORKSTATION__}]" \
    "[$__CONST_REPLACE__] [${__CONST_YES__}] [${__CONST_FILE__} path to file]"
}

function err {
  echo "[ERR][ssh-authorized-keys] $*" >&2
  __ERR__=1
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
  local p prev arg

  for p in "$@"; do
    arg=1
    case $p in
    "$__CONST_YES__") __ARG_YES__=1 ;;
    "$__CONST_REPLACE__") __ARG_REPLACE__=1 ;;
    "$__CONST_ALL__")
      __AUTHORIZED_KEYS__=$(grep -Eiv '(^#|^$)' "$__KEYS_FILE__")
      ;;
    "$__CONST_SERVER__")
      __AUTHORIZED_KEYS__=$(grep -iA 1 "server" $__KEYS_FILE__ | grep -viE '(^\-|^#|^$)')
      ;;
    "$__CONST_WORKSTATION__")
      __AUTHORIZED_KEYS__=$(grep -iA 1 "workstation" $__KEYS_FILE__ | grep -viE '(^\-|^#|^$)')
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

checkFileExist "$__KEYS_FILE__" || exit 1
parseArgs $@

[ -z "$__AUTHORIZED_KEYS__" ] && err "not passed type"

if [ -n "$__ARG_FILE_ON__" ]; then
  [ -z "$__ARG_FILE__" ] && err "not processed file name for ${__CONST_FILE__}"
  [ -d "$__ARG_FILE__" ] && err "'$__ARG_FILE__' is not a file"
fi

[ -n "$__ERR__" ] && help && exit 1

# just output to the stdout
if [ -z "$__ARG_FILE_ON__" ]; then
  echo -e "$__AUTHORIZED_KEYS__"
  exit 0
fi

function confirm {
  local ans
  read -rp "File '${__ARG_FILE__}' is not empty, delete [y/N] ?: " ans
  case "$ans" in
  "y" | "Y") return 0 ;;
  *) echo "cancel action" ;;
  esac
  return 1
}

# save to file
if [ -n "$__ARG_REPLACE__" ] && [ -s "$__ARG_FILE__" ]; then
  [ -n "$__ARG_YES__" ] || confirm || exit 0
  rm -rf "$__ARG_FILE__"
fi

if [ ! -f "$__ARG_FILE__" ]; then
  touch "$__ARG_FILE__" || exit 1
fi

function notContainKeyPub {
  local line keyPub=$1
  cat "$__ARG_FILE__" | while read line; do
    if [ "${keyPub%==*}" = "${line%==*}" ]; then
      return 1
    fi
  done
}

echo "$__AUTHORIZED_KEYS__" | while read REC; do

  [ -z "$REC" ] && echo "!!!!!"

  notContainKeyPub "$REC" || continue
  echo "$REC" >>"$__ARG_FILE__"
done
