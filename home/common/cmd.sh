#!/bin/bash

## external IP
# TODO - added alternative methods
# curl -w'\n' ifconfig.me
# echo $(curl -s 2ip.ru)
# wget -qO- eth0.me
alias myip='wget -qO myip http://www.ipchicken.com/; grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" myip; rm -f myip'

# find with ping on local network
# example:
# echo 192.168.1.{1..254} | xargs -n1 -P0 ping -c1 | grep "bytes from"
# TODO edit for linux
function scanLocalNet {
  local ip net div="scanLocalNet"
  ip=$(hostname) || (echo "error get of local ip" && return 1)

  while true; do
    echo "$ip" | grep -iE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.[0-9]{1,3}$'
    [ $? -eq 0 ] && break
    echo "enter IP address manally in format [xxx.xxx.xxx.xxx]: "
    read ip
  done

  net="${ip%.*}"
  echo "${div}: local_ip = ${ip}  part of ip = ${net}"
  echo "${div}: start-****************************************"

  # TODO clear command output and leave only ip
  echo "${net}".{1..254} | xargs -n1 -P0 ping -c1 | grep "bytes from"
  echo "${div}: end-******************************************"
}
