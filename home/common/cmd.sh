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
function scanLocalNet {
  local ip net div="scanLocalNet"

  if [ -n "$__SELF_OS_IS_UNIX__" ]; then
    ip=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')
  else
    ip=$(hostname -I | awk '{print $1}')
  fi

  while true; do
    echo "$ip" | grep -iE -q '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.[0-9]{1,3}$' && break
    echo "enter IP address manally in format [xxx.xxx.xxx.xxx]: "
    read ip
  done

  net="${ip%.*}"

  echo "${div}: start-****************************************"
  echo "${net}".{1..254} | xargs -n1 -P0 ping -c1 | grep "bytes from"
  echo "${div}: end-******************************************"
}

function temp {
  if [ -n "$__SELF_OS_IS_UNIX__" ]; then
    sudo powermetrics | grep -i "CPU die temperature"
    return 0
  fi

  if [ -n "$__SELF_OS_IS_RASPBIAN__" ]; then
    watch -t -n 1 vcgencmd measure_temp
  fi
}
