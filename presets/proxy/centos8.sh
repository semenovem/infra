#!/bin/bash

exit 0

sudo apt-get upgrade
sudo apt-get update

# SSH
sudo vim /etc/ssh/sshd_config
PasswordAuthentication no
PermitRootLogin no
systemctl restart sshd.service

#----------
sudo dnf --enablerepo=powertools -y install fuse-sshfs

# for docker
sudo sshfs -o allow_other \
  -p 2022 remote@localhost:/mnt/usb_500/_make_cloud_torrent_  /home/centos/dev/downloads


sshfs -o idmap=user,allow_other,reconnect,nonempty \
  home:/mnt/raid1t_soft/torrents /downloads/

# SQUID
sudo apt-get -y install squid squid-common httpd-tools

sudo service squid start
sudo systemctl enable squid
sudo systemctl restart squid

sudo touch /etc/squid/passwd && sudo chown squid /etc/squid/passwd
sudo htpasswd /etc/squid/passwd user_name

sudo vim /etc/squid/squid.conf
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic realm Squid Basic Authentication
auth_param basic credentialsttl 2 hours
acl auth_users proxy_auth REQUIRED
http_access allow auth_users

forwarded_for truncate
# ++ change port to 33443

# Access log: /var/log/squid/access.log
# Cache log: /var/log/squid/cache.log

# Only set values in the config file
grep -Eiv '(^#|^$)' /etc/squid/squid.conf
