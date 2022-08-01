#!/bin/sh

# https://github.com/cilynx/rtl88x2bu

# Update all packages per normal
sudo apt update && \
sudo apt -y upgrade && \
sudo apt -y update && sudo DEBIAN_FRONTEND=noninteractive apt -y install hostapd \
  dnsmasq openvpn netfilter-persistent iptables-persistent lshw vim mc iptraf-ng \
  git raspberrypi-kernel-headers build-essential dkms autossh iperf bc sshfs


# ----------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------
# commit 9957138ac30529a06bfcbc36eb51006a948b0967
# branch 5.8.7.1_35809.20191129_COEX20191120-7777
git clone https://github.com/cilynx/rtl88x2bu
cd rtl88x2bu
sed -i 's/I386_PC = y/I386_PC = n/' Makefile
sed -i 's/ARM_RPI = n/ARM_RPI = y/' Makefile

VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
sudo rsync -rvhP ./ /usr/src/rtl88x2bu-${VER}
sudo dkms add -m rtl88x2bu -v ${VER}
sudo dkms build -m rtl88x2bu -v ${VER}
sudo dkms install -m rtl88x2bu -v ${VER}




# ----------------------------------------------------------------------------
sudo vim /etc/udev/rules.d/70-persistent-net.rules
```
# built-in
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="dc:a6:32:a2:4a:54", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan0"

# ASUSTek Computer, Inc. 802.11ac NIC
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="04:42:1a:5b:95:fc", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan2"

# ASUSTek Computer, Inc. 802.11ac NIC (rezerv)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="04:42:1a:48:b6:8a", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan2"

# TP-Link TL-WN722N v2/v3 [Realtek RTL8188EUS] (not work)
#SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="14:eb:b6:54:da:69", ATTR{dev_id}=="0x0", ATTR{type}=="1", NAME="wlan5"

```

# ----------------------------------------------------------------------------
sudo vim /etc/dhcpcd.conf
#```
interface wlan2
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
#```

# ----------------------------------------------------------------------------
sudo vim /etc/dnsmasq.conf
#```
interface=wlan2
  dhcp-range=192.168.4.100,192.168.4.199,255.255.255.0,24h
#```

# ----------------------------------------------------------------------------
sudo vim /etc/hostapd/hostapd.conf
#```
interface=wlx74ee2ae24062
interface=wlan2
driver=nl80211
ssid=apt024
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=121212232323343434
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
hw_mode=a
channel=36
wmm_enabled=1
country_code=US
require_ht=1
ieee80211ac=1
require_vht=1
#This below is supposed to get us 867Mbps and works on rtl8814au doesn't work on this driver yet
#vht_oper_chwidth=1
#vht_oper_centr_freq_seg0_idx=157
ieee80211n=1
ieee80211ac=1
#```

# ----------------------------------------------------------------------------
sudo sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

# ----------------------------------------------------------------------------
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl status hostapd
sudo systemctl restart hostapd


sudo reboot


# --------------
# troubleshooting
# --------------

# проблемы со стартом AP (err: nl80211: kernel reports: Match already configured)
sudo systemctl stop NetworkManager
sudo killall wpasupplicant | sudo killall wpa_supplicant
sudo systemctl disable NetworkManager
