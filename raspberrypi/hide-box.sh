#!/bin/bash

# wifi point
https://raspberrypi.ru/wireless_access_point

sudo apt -y install hostapd dnsmasq openvpn
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

sudo vim /etc/dhcpcd.conf
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant


sudo vim /etc/sysctl.d/routed-ap.conf
# Enable IPv4 routing
net.ipv4.ip_forward=1

# eth0 = tun0
# ls -l /etc/iptables/
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE


# print the kernel ring buffer
dmesg
ifconfig -a
sudo ifconfig usb0 up
sudo dhclient usb0

