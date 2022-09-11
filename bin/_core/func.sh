#!/bin/sh

# Запрос подтверждения
# Если __YES__= 1, то yes
# return 0 - yes
# return 1 - no
__confirm__() {
  [ -n "$__YES__" ] && return 0
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

# Копирование файла, если необходимо
# $1 - файл-источник (оригинал)
# $2 - файл-приемник (копия)
# ret 0 - файлы совпадают
# ret 100 - копирование успешно
# ret 1 - ошибка - нет файла-источника
# ret 2 - ошибка - при операции копирования
__copy_if_need_file_to__() {
  source=$1
  target=$2

  [ ! -f "$source" ] && echo "Нет файла-источника '$source'" >&2 && return 1

  # файлы идентичные
  [ -f "$target" ] && cmp -s "$target" "$source" &&
    echo "Файлы идентичные" &&
    return 0

  cp "$source" "$target" || return 1

  echo "Копирование успешно"
  return 0
}
