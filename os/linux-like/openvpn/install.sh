#!/bin/bash



mkdir -p /var/log/openvpn

# https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-centos-8

sudo vim /etc/sysctl.conf
# insert
net.ipv4.ip_forward = 1

sudo firewall-cmd --get-active-zones

sudo firewall-cmd --zone=trusted --add-interface=tun+
sudo firewall-cmd --permanent --zone=trusted --add-interface=tun+

sudo firewall-cmd --permanent --add-service openvpn
sudo firewall-cmd --permanent --zone=trusted --add-service openvpn
sudo firewall-cmd --reload

sudo firewall-cmd --list-services --zone=trusted
sudo firewall-cmd --add-masquerade
sudo firewall-cmd --add-masquerade --permanent

sudo firewall-cmd --query-masquerade

DEVICE=$(ip route | awk '/^default via/ {print $5}')
sudo firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.5.0/24 -o $DEVICE -j MASQUERADE
sudo firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.1.0/24 -o $DEVICE -j MASQUERADE
sudo firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.6.0/24 -o $DEVICE -j MASQUERADE
sudo firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.7.0/24 -o $DEVICE -j MASQUERADE

sudo firewall-cmd --reload

#
sudo systemctl -f enable openvpn-server@server-udp
sudo systemctl start openvpn-server@server-udp
sudo systemctl stop openvpn-server@server-443-tcp
sudo systemctl status openvpn-server@server-443-tcp

systemctl reset-failed
systemctl daemon-reload

# ----------------

sudo systemctl -f enable openvpn-server@server-udp
sudo systemctl start openvpn-server@server-udp
sudo systemctl stop openvpn-server@server-udp
sudo systemctl status openvpn-server@server-udp


