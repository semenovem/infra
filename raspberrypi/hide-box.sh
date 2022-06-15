#!/bin/bash

sudo apt -y update && sudo DEBIAN_FRONTEND=noninteractive apt -y install hostapd \
  dnsmasq openvpn netfilter-persistent iptables-persistent lshw vim mc iptraf-ng \
  git raspberrypi-kernel-headers build-essential dkms autossh iperf

# locale
sudo vim /etc/default/locale
```
#  File generated by update-locale
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_ALL=en_US.UTF-8
```

sudo vim /etc/environment
```
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
```

sudo localedef -i en_US -f UTF-8 en_US.UTF-8

# -----------------------------------------------
# -----------------------------------------------
sudo vim /etc/dhcpcd.conf
```
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
```

# check
sudo rfkill unblock wlan

# -----------------------------------------------
# -----------------------------------------------
sudo vim /etc/hostapd/hostapd.conf
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
wpa_passphrase=121212232323343434
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

# -----------------------------------------------
# -----------------------------------------------
# Enable IPv4 routing
sudo vim /etc/sysctl.d/routed-ap.conf
```
net.ipv4.ip_forward=1
```
# or
sudo vim /etc/sysctl.conf
uncomment #net.ipv4.ip_forward=1

# iptables
# eth0 = tap0
# ls -l /etc/iptables/
sudo iptables -t nat -A POSTROUTING -o tap0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o gatewaytun -j MASQUERADE
sudo netfilter-persistent save

sudo iptables -t nat -D POSTROUTING 1
sudo iptables -t nat -L -v

sudo ip route add default dev wlan0 metric 50


# -----------------------------------------------
# -----------------------------------------------
# Setup DHCP и DNS
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo vim /etc/dnsmasq.conf
```
interface=wlan0 # Listening interface
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
# Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.4.1 # Alias for this router
```

# -----------------------------------------------
# -----------------------------------------------
sudo vim /etc/udev/rules.d/70-persistent-net.rules
```
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="dc:a6:32:a2:4a:54", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan0"
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="b0:a7:b9:6a:2b:47", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan3"
```

# -----------------------------------------------
# -----------------------------------------------
# setup wi-fi
sudo vim /etc/wpa_supplicant/wpa_supplicant.conf
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=RU

network={
        ssid="VERA24"
        psk="31415926"
        key_mgmt=WPA-PSK
        scan_ssid=1
}

network={
        ssid="v8_io"
        psk="55555555"
        key_mgmt=WPA-PSK
}
```

# -----------------------------------------------
# -----------------------------------------------

sudo systemctl unmask hostapd
sudo systemctl enable hostapd


# print the kernel ring buffer
dmesg
sudo ifconfig usb0 up
sudo dhclient usb0

