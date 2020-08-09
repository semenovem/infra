#!/bin/bash


sudo route -n add 192.168.1.9 192.168.1.1

sudo route -n delete default -link 8


# deprecated
cat /etc/resolv.conf

#
scutil --dns

#
networksetup -getdnsservers Wi-Fi

networksetup -setdnsservers Wi-Fi 192.168.43.1
networksetup -setdnsservers Wi-Fi 192.168.1.1

# 192.168.43.1

networksetup -setdnsservers "USB 10/100/1000 LAN" 10.132.168.11 10.132.168.203


networksetup -setdnsservers "USB 10/100/1000 LAN" 10.132.168.11 10.132.168.203



-------

# An asterisk (*) denotes that a network service is disabled
networksetup listallnetworkservices
