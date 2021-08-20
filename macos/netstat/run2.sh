#!/bin/bash







#exit


# удаление локальных маршрутов
LIST=$(netstat -nr | grep 192. | grep utun | awk '{print $1}')

for addr in $LIST; do
  echo "deleting: $addr  $(sudo route -n delete "$addr")"
#  sudo route -n delete "$addr"
done
