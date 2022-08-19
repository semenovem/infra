#!/bin/sh

#
# Установка профилей и стартоваая настройка
#

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
source "${ROOT}/_core/os.sh"
source "${ROOT}/_core/logger.sh"

BIN_DIR="$ROOT"
LINUX_BIN_DIR="${ROOT}/linux"
MACOS_BIN_DIR="${ROOT}/macos"

profile() {
  profileFile=$1
  binDir=$2

  [ ! -f "$profileFile" ] && __err__ "Файла профиля не существует '$profileFile'"
  grep -i "$binDir" "$profileFile" -q && __debug__ "Профиль уже добавлен" && return 0

  [ -n "$(tail -n1 "$profileFile")" ] && echo "" >>$profileFile

  echo "## настройки системы environment" >>$profileFile
  echo "export PATH=${binDir}:${PATH}" >>$profileFile
  echo "" >>$profileFile
}

check() {
  profileFile="${HOME}/$1"
  shift

  for bin in $@; do
    profile "$profileFile" "$bin"
  done
}

case "$__CORE_OS_KIND__" in
"$__CORE_OS_KIND_MACOS_CONST__")
  check ".zshrc" "$BIN_DIR" "$MACOS_BIN_DIR"
  ;;

"$__CORE_OS_KIND_LINUX_CONST__")
  check ".bashrc" "$BIN_DIR" "$LINUX_BIN_DIR"
  ;;

*) __err__ "Не определен тип OS" ;;
esac
