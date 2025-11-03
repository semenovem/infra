#!/bin/sh

# apt install wireguard

wg genkey | tee wg-mini-private.key |  wg pubkey > wg-mini-public.key
wg genkey | tee wg-server-srv2-prv.key |  wg pubkey > wg-server-srv2-pub.key

wg genkey | tee wg-alex-private.key |  wg pubkey > wg-alex-public.key


# home 51820-51820


-----------
apt/dnf install qrencode

qrencode -t ansiutf8 -r wg.conf
qrencode -t png -o file_with_qr.png -r wg.conf





-------------------------------
-------------------------------
-------------------------------

# /etc/wireguard/wg0.conf
# server-srv2 config

# sudo wg-quick up wg0
# sudo wg-quick down wg0
# wg show
# sudo systemctl enable wg-quick@wg0
# sudo systemctl status wg-quick@wg0

# sudo ufw allow 44400/udp
# sudo ufw status

# 192.168.11.102/24

[Interface]
Address = 10.200.200.1/24
ListenPort = 44400

PrivateKey = 

# PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# mini
PublicKey = dkMMedcWBASw+mlhTS3ohe9IsK6xrVtCYEynwUIZ1lM=
AllowedIPs = 10.200.200.2/32
# 192.168.12.0/24

[Peer]
# mobile phone
PublicKey = iQwpO7MXlbyHrclIJUXIjOhvebPjasW+16Nh6BrTBGM=
AllowedIPs = 10.200.200.3/32
# , 192.168.12.0/24
