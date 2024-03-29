#!/bin/sh

# Копирование файла, если необходимо
# $1      - файл-источник (оригинал)
# $2      - файл-приемник (копия)
# ret 0   - файлы совпадают
# ret 100 - копирование успешно
# ret 1   - ошибка - нет файла-источника
# ret 2   - ошибка - при операции копирования

SOURCE=$1
TARGET=$2

[ ! -f "$SOURCE" ] && echo "No source file '$SOURCE'" >&2 && exit 1

# файлы идентичные
[ -f "$TARGET" ] && cmp -s "$TARGET" "$SOURCE" &&
  echo "The files are identical" &&
  exit 0

cp "$SOURCE" "$TARGET" || exit 1

echo "Copying successful"
