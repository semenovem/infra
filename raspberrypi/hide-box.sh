#!/bin/bash

# wifi point
https://raspberrypi.ru/wireless_access_point

sudo apt -y install hostapd dnsmasq openvpn
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

# -----------
sudo vim /etc/dhcpcd.conf
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant

sudo rfkill unblock wlan

# -----------
/etc/hostapd/hostapd.conf
```
country_code=RU
interface=wlan0
ssid=apt024
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=...............
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

sudo vim /etc/sysctl.d/routed-ap.conf
# Enable IPv4 routing
net.ipv4.ip_forward=1
# or
/etc/sysctl.conf
uncomment #net.ipv4.ip_forward=1

# eth0 = tun0
# ls -l /etc/iptables/
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo netfilter-persistent save

# print the kernel ring buffer
dmesg
ifconfig -a
sudo ifconfig usb0 up
sudo dhclient usb0

