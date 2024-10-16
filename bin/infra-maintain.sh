#!/bin/sh

. "${__INFRA_BIN__}/_lib/core.sh" || exit 1

while :
do
  echo ">>> $(date +%H:%M)"

  sleep 60

  # - запустить git получение данных 1раз/день (утро)

  # - запустить sync 1 раз в час в дневное время

  # - запустить полный backup (1 раз в мес например) в ночное время

done
