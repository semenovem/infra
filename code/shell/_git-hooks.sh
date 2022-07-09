#!/bin/sh

# ******************************************************************************
# перенос / удаление файлов git-hooks в git директорию                         *
# при установке подхватит и перенесёт файлы стандартных названий (.git/hooks)  *
# ******************************************************************************

_BIN_=$(dirname "$([ "$0" = '/*' ] && echo "$0" || echo "$PWD/${0#./}")")

_HOOKS_DIR_="${_BIN_}/../../.git/hooks"
_SOURCE_DIR_="${_BIN_}"
_PROC_="git-hooks-"
_RED_='\033[0;31m'
_GREEN_='\033[0;32m'
_YELLOW_='\033[1;33m'
_NC_='\033[0m'
_RED_='\033[0;31m'
_GREEN_='\033[0;32m'
_YELLOW_='\033[1;33m'
_CYAN_='\033[0;36m'

_HOOKS_="pre-rebase pre-receive prepare-commit-msg post-update pre-merge-commit pre-applypatch pre-commit pre-push update push-to-checkout"

info() {
  echo "${_GREEN_}[INFO][${_PROC_}]${_NC_} $*"
}

err() {
  echo "${_RED_}[ERRO][${_PROC_}]${_NC_} $*"
}

[ ! -d "$_HOOKS_DIR_" ] && err "No directory .git/hooks" && exit 1
[ ! -d "$_SOURCE_DIR_" ] && err "No directory ${_SOURCE_DIR_}" && exit 1

www() {
  while true; do
    read -rp "$1: " ans
    case "$ans" in
    "y" | "Y") return 0 ;;
    "n" | "N" | "")
      echo "skipped"
      return 10
      ;;
    esac
  done
}

install() {
  affect=
  for fileName in $_HOOKS_; do
    path=$(find "$_SOURCE_DIR_" -type file -name "$fileName")
    [ -z "$path" ] && continue
    [ ! -f "$path" ] && continue
    affect=1

    fileName=$(echo "$path" | grep -iEo '[^/]+$')
    echo "$fileName" | grep -iE '^\..*' -q && continue
    newPath="${_HOOKS_DIR_}/${fileName}"

    if [ -f "$newPath" ]; then
      msg=$(info "file exists ${_CYAN_}${newPath}${_NC_} ${_YELLOW_}Overwrite ? [y/N]${_NC_}")

      www "$msg"
      ret=$?

      [ "$ret" -eq 10 ] && continue
      [ "$ret" -ne 0 ] && return 1
    fi

    cp "$path" "$newPath" || return $?
    info "saved file $fileName"
  done
  [ -z "$affect" ] && info "no files to move"
  return 0
}

uninstall() {
  affect=
  for fileName in $_HOOKS_; do
    path=$(find "$_HOOKS_DIR_" -type file -name "$fileName")
    [ -z "$path" ] && continue
    [ ! -f "$path" ] && continue
    affect=1

    msg=$(info "file ${_CYAN_}${path}${_NC_} ${_YELLOW_}Delete ? [y/N]${_NC_}")

    www "$msg"
    ret=$?

    [ "$ret" -eq 10 ] && continue
    [ "$ret" -ne 0 ] && return 1

    rm -f "$path" || return $?
  done
  [ -z "$affect" ] && info "no files to delete - this is okay"
  return 0
}

case "$1" in
'install')
  _PROC_="${_PROC_}-install"
  info "start"
  install
  ;;

'uninstall')
  _PROC_="${_PROC_}-uninstall"
  info "start"
  uninstall
  ;;
esac
