#!/bin/sh

# Настройка proxy сервер на centos
# -------------------------------
echo "LANG=en_US.utf-8" >>"/etc/environment"
echo "LC_ALL=en_US.utf-8" >>"/etc/environment"

yum -y update && yum -y install epel-release && yum -y update && yum -y upgrade &&
  yum -y install \
    squid httpd-tools net-tools lsof bind-utils vnstat openvpn iperf \
    firewalld mc htop sshfs git vim

adduser adman
usermod -aG wheel adman

runuser -l adman -c 'whoami'
runuser -l adman -c 'git clone https://github.com/semenovem/environment.git _environment'
#runuser -l adman -c 'sh _environment/bin/envi'

# ------------------
#
# sudo without pass - manual
# visudo
# adman ALL=(ALL) NOPASSWD: ALL

echo "# sudo for adman" >> /etc/sudoers.d/10-adman
echo "adman ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/10-adman

# -------------------------------
grep -Eiq 'net.ipv4.ip_forward\s*=\s*1' /etc/sysctl.conf ||
  echo "net.ipv4.ip_forward = 1" >/etc/sysctl.conf

sysctl -p

# -----------------
# firewall-cmd --permanent --list-all

firewall-cmd --zone=public --permanent \
  --add-port 8080/tcp \
  --add-port 443/tcp \
  --add-port 443/udp \
  --add-port 2257/tcp \
  --add-port 33440/tcp \
  --add-port 33440/tcp \
  --add-port 33443/tcp \
  --add-port 33443/udp \
  --add-port 5001/tcp \
  --add-port 5001/udp \
  --add-port 17593/tcp \
  --add-port 27593/tcp

firewall-cmd --reload

firewall-cmd --get-active-zones

# tun 0
firewall-cmd --zone=trusted --add-interface=tun0
firewall-cmd --permanent --zone=trusted --add-interface=tun0
# tun 1
firewall-cmd --zone=trusted --add-interface=tun1
firewall-cmd --permanent --zone=trusted --add-interface=tun1
# tun 7
firewall-cmd --zone=trusted --add-interface=tun7
firewall-cmd --permanent --zone=trusted --add-interface=tun7

firewall-cmd --permanent --add-service openvpn
firewall-cmd --permanent --zone=trusted --add-service openvpn

firewall-cmd --reload
firewall-cmd --list-services --zone=trusted

firewall-cmd --add-masquerade
firewall-cmd --add-masquerade --permanent
firewall-cmd --query-masquerade

DEVICE=$(ip route | awk '/^default via/ {print $5}')
# подсети vpn - от всех экземпляров
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$DEVICE" -j MASQUERADE
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.1.0/24 -o "$DEVICE" -j MASQUERADE
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.6.0/24 -o "$DEVICE" -j MASQUERADE
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.7.0/24 -o "$DEVICE" -j MASQUERADE

firewall-cmd --reload

# ------------------
mkdir -p /var/log/openvpn


# ################################
# ################################

# SSH
vim /etc/ssh/sshd_config
PasswordAuthentication no
PermitRootLogin no
# для проброса внутреннего порта на внешний
GatewayPorts yes

# setenforce 0 - если ошибка по новому порту
systemctl restart sshd.service
