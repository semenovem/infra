#!/bin/sh

# продолжить с последнего файла
# получить данные из файла статистики
# указать файл статистики (если новый/не существует - запросить доп параметры)

COUNT=0
FILE_STAT=stat.txt

SCRIPT_START=$(date)
echo "script start: (${SCRIPT_START})" >>"$FILE_STAT"

# $1 - time start
# $2 - time end
diffSec() {
  echo $(($(date -d "$2" +%s) - $(date -d "$1" +%s)))
}

while true; do
  NUM=$(printf %0*d 4 $COUNT)
  FILE="/media/adman/2tali/dat.${NUM}"
#  FILE="dat.${NUM}"

  GENERATE_FILE_START=$(date)
  head -c 5G </dev/urandom >"$FILE"
  GEN_FILE_END=$(date)

  CHECK_SUM=$(sha256sum "$FILE")

  TOTAL_AGO=$(printf %0*d 7 "$(diffSec "$SCRIPT_START" "$GEN_FILE_END")")
  GENERATE_SEC=$(printf %0*d 3 "$(diffSec "$GENERATE_FILE_START" "$GEN_FILE_END")")

  echo "${NUM} ${TOTAL_AGO} ${GENERATE_SEC} ${CHECK_SUM} " >>"$FILE_STAT"

  COUNT=$((COUNT + 1))
  sleep 2
done
