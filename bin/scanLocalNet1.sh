#!/bin/sh

BIN=$(dirname "$([ "${0:0:1}" = "/" ] && echo "$0" || echo "$PWD/${0#./}")")
sourse "${BIN}/common.sh"

echo "scanLocalNet1"

exit 0

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
