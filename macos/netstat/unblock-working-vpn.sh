#!/bin/bash


NS='Wi-Fi'
NS='USB 10/100/1000 LAN'

ROUTER=$(networksetup -getinfo "${NS}" | grep -Ei ^router: | grep -Eo '[[:digit:].]+')

#networksetup -setdnsservers "$NS" "$ROUTER"

echo ">>>$ROUTER"

DNS=$(networksetup -getdnsservers "$NS")
LEN_DNS=$(echo "$DNS" | wc -l)
LEN_DNS="$(echo -e "${LEN_DNS}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
echo ">> $LEN_DNS"

[ "$LEN_DNS" -lt "2" ] && exit 0

for it in $DNS; do
  [ "$it" = "$ROUTER" ] && exit 0
  break
done



#echo "$DNS"

#netstat -nr | grep 192. | grep utun3


# remove local routing

#echo "$ROUTER"
#
#dns=$(networksetup -getdnsservers "$NS")
#
#for it in $dns
#do
#  echo - "$it"
#done



