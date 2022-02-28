#!/bin/bash

# only macos

# connect to work hldgapp20..
function hldg() {
  local cmd="ssh -fNL 4022:localhost:4022 ru" TRY req pids
  ps -A | grep "$cmd" | grep -vq grep

  if [ $? -ne 0 ]; then
    TRY=0
    while true; do
      ((TRY++))
      ssh -fNL 4022:localhost:4022 ru && break

      [ "$TRY" -gt 5 ] && echo "ERR: Connection error to '$cmd'" && exit 1
      echo "waiting before next connection attempt (attempt number: ${TRY})"
      sleep 5
    done
  fi

  ssh -p 4022 -i ~/.ssh/id_rsa_vtb_hldg hldgadm@localhost

  req="ssh -p 4022 -i /Users/sem/.ssh/id_rsa_vtb_hldg hldgadm@localhost"
  ps -A | grep "$req" | grep -vq grep && return 0

  pids=$(ps -A | grep "$cmd" | grep -v grep | awk '{print $1}')
  kill -1 $pids
}
