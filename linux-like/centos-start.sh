#!/bin/sh

yum -y update && yum -y install epel-release && yum -y update && yum -y upgrade &&
  yum -y install \
    squid httpd-tools net-tools lsof bind-utils vnstat openvpn iperf \
    firewalld mc htop sshfs git

adduser adman
usermod -aG wheel adman

runuser -l adman -c 'whoami'
runuser -l adman -c 'git clone https://github.com/semenovem/environment.git _environment'
runuser -l adman -c 'sh _environment/bin/envi'

# -----------------
# firewall-cmd --permanent --list-all

firewall-cmd --zone=public --permanent \
  --add-port 80/tcp \
  --add-port 80/tcp \
  --add-port 443/tcp \
  --add-port 443/udp \
  --add-port 2257/tcp \
  --add-port 33443/tcp \
  --add-port 33443/udp \
  --add-port 43443/tcp \
  --add-port 43443/udp \
  --add-port 5001/tcp \
  --add-port 5001/udp

firewall-cmd --reload



# -------------------------------
grep -Eiq 'net.ipv4.ip_forward\s*=\s*1' /etc/sysctl.conf ||
  echo "net.ipv4.ip_forward = 1" >/etc/sysctl.conf

# ------------------
mkdir -p /var/log/openvpn

#
sudo systemctl list-units 'openvpn-server*' -all | grep -i 'openvpn-server' | awk '{print $1}'
