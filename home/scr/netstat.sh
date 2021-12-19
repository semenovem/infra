#!/bin/bash

# удаление локальных маршрутов рабочего vpn
LIST=$(netstat -nr | grep 192. | grep utun | awk '{print $1}')

for addr in $LIST; do
  echo "deleting: $addr $(sudo route -n delete "$addr")"
done
