#!/bin/bash

# common setup
# https://serveradmin.ru/centos-nastroyka-servera/

# routing
# https://www.dmosk.ru/miniinstruktions.php?mini=router-centos

# vpn setup
# https://www.dmosk.ru/instruktions.php?object=openvpn-centos-install
# https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-centos-8

exit 0

yum update
yum upgrade
yum -y install squid squid-common httpd-tools net-tools lsof bind-utils


# ################################
# USER
adduser adman
usermod -aG wheel adman

# sudo without pass
visudo
adman ALL=(ALL) NOPASSWD: ALL


# ################################
# SSH
vim /etc/ssh/sshd_config
PasswordAuthentication no
PermitRootLogin no
systemctl restart sshd.service


# ################################
# TODO: check it for macos ?
# remote mount
apt --enablerepo=powertools -y install fuse-sshfs

# for docker
sshfs -o allow_other \
  -p 2022 remote@localhost:/mnt/usb_500/_make_cloud_torrent_  /home/centos/dev/downloads

sshfs -o idmap=user,allow_other,reconnect,nonempty \
  home:/mnt/raid1t_soft/torrents /downloads/


# ################################
# SQUID
apt yum -y install squid httpd-tools

# copy file squid-centos8.conf
# ++ change port to 33443

# SQUID config authentication
touch /etc/squid/passwd
chown squid /etc/squid/passwd
# `proxy` - username
htpasswd /etc/squid/passwd proxy
# add in config file:
vim /etc/squid/squid.conf
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic realm Squid Basic Authentication
auth_param basic credentialsttl 2 hours
acl auth_users proxy_auth REQUIRED
http_access allow auth_users
forwarded_for truncate

# Access log: /var/log/squid/access.log
# Cache log: /var/log/squid/cache.log

# Only set values in the config file
grep -Eiv '(^#|^$)' /etc/squid/squid.conf

# SQUID - start
service squid start
systemctl enable squid
# systemctl restart squid

# ################################
# OPENVPN
# TODO -
sudo systemctl -f enable openvpn-server@server.service
sudo systemctl restart openvpn-server@server.service
sudo systemctl status openvpn-server@server.service



# ################################
# FIREWALL
# if not - intall firewalld
yum install firewalld -y
systemctl start firewalld

firewall-cmd --permanent --list-all
firewall-cmd --get-services
firewall-cmd --get-zones
firewall-cmd --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-port 8080/tcp
firewall-cmd --reload
