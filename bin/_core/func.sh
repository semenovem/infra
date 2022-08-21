#!/bin/sh

__confirm__() {
  msg="Подтвердить ?"
  [ -n "$1" ] && msg="$1"

  while true; do
    read -rp "$msg  [y/N]: " ans

    case $ans in
    "y" | "Y") return 0 ;;
    "" | "n" | "N") return 1 ;;
    esac
  done
}

#   Проверить, добавлен ли путь в PATH
__is_dir_added_to_path__() {
  for p in $(echo "$PATH" | tr ":" "\n"); do
    [ "$p" = "$1" ] && return 0
  done

  return 1
}
