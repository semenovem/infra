#!/bin/sh

# Updating all git-repositories
# $.. - path to the directory with git repositories,
#       if not specified, take the current one, from where the script is called
# $.. = -dry do not perform `git pull`

_NC_='\033[0m'
_BACKGROUND_DARK_BLUE_='\033[44m'
_DRY_=

for p in "$@"; do
  case "$p" in
    "-dry") _DRY_=1; shift;;
    "-"*) echo "[ERRO] unknown flag [${p}]" 1>&2; exit 1 ;;
  esac
done

_CURRENT_DIR_=$1
[ -z "$_CURRENT_DIR_" ] && _CURRENT_DIR_="$PWD"


[ ! -d "$_CURRENT_DIR_" ] && echo "[ERRO] dir [${_CURRENT_DIR_}] not exist" 1>&2 && exit 1

# this is git repo
# $1 - directory
func_git_repo() {
  NOT_CLEAR=
  SUCCESS_PULL="\e[1;32mINFO\e[m"
  DIR=$1

  git -C "$DIR" diff --exit-code 1>/dev/null &&
  git -C "$DIR" diff --cached --exit-code  1>/dev/null || NOT_CLEAR=1

  BRANCH=$(git -C "$DIR" rev-parse --abbrev-ref HEAD) || exit

  PRE_DIR="$(dirname "$DIR")"
#  to show 3 directories in the displayed path
#  PRE_PRE_DIR="$(dirname "$PRE_DIR")"
#  SHOW_DIR="$(basename "$PRE_PRE_DIR")/$(basename "$PRE_DIR")/$(basename "$DIR")"
  SHOW_DIR="$(basename "$PRE_DIR")/$(basename "$DIR")"

  if [ -z "$_DRY_" ]; then
    git -C "$DIR" pull origin --no-rebase --no-commit -q || SUCCESS_PULL="\e[1;31mERRO\e[m"
  fi

  printf "[$SUCCESS_PULL] %-50s  " "$SHOW_DIR"

  [ -n "$NOT_CLEAR" ] && NOT_CLEAR="not clear"
  echo "[${_BACKGROUND_DARK_BLUE_}${BRANCH}${_NC_}] ${NOT_CLEAR}"
}

if [ -d "${_CURRENT_DIR_}/.git" ]; then
  func_git_repo "$_CURRENT_DIR_"
  exit
fi

# iterate dirs
# $1 - directory
func_iterator() {
  for ITERATOR_ITEM in "${1}"/*; do
    [ ! -d "$ITERATOR_ITEM" ] && continue

    if [ -d "${ITERATOR_ITEM}/.git" ]; then
      func_git_repo "$ITERATOR_ITEM"
     else
       func_iterator "$ITERATOR_ITEM"
     fi
  done
}

func_iterator "$_CURRENT_DIR_"
