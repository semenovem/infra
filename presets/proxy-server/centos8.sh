#!/bin/bash

sudo vim /etc/ssh/sshd_config

PasswordAuthentication yes
PasswordAuthentication no

systemctl restart sshd.service

#----------
sudo dnf --enablerepo=powertools -y install fuse-sshfs


# для docker
sudo sshfs -o allow_other \
  -p 2022 remote@localhost:/mnt/usb_500/_make_cloud_torrent_  /home/centos/dev/downloads
