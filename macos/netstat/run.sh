#!/bin/bash

while true; do
  echo
  echo "**************************************"

  bash unblock-working-vpn.sh

  echo "**************************************"
  sleep 1
  read -rn 1 -p "Press any key to continue.."
  echo

done
