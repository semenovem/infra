#!/bin/bash

# удаление локальных маршрутов рабочего vpn
function vtb_local_ip() {
  local addr list=$(netstat -nr | grep 192. | grep utun | awk '{print $1}')

  for addr in $list; do
    echo "deleting: $addr $(sudo route -n delete "$addr")"
  done
}
