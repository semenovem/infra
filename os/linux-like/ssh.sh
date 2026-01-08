#!/usr/bin/env bash


# https://man7.org/linux/man-pages/man5/ssh_config.5.html

sudo vim /etc/ssh/sshd_config
PasswordAuthentication no
PermitRootLogin no
AllowTcpForwarding yes
GatewayPorts yes

# setenforce 0 - если ошибка по новому порту
systemctl restart sshd.service


### показать логи ssh
journalctl -u ssh -f


# --- Usage example -----------------------------------------------------

############################################################
# SSH: Run Commands or Scripts Remotely
# https://www.shellhacks.com/ru/ssh-execute-remote-command-script-linux/


ssh root@192.168.1.1 << EOF
  uname -a
  lscpu  | grep "^CPU(s)"
  grep -i memtotal /proc/meminfo
EOF

ssh root@192.168.1.1 'bash -s' < script.sh

############################################################
# ssh tunnel
# https://qastack.ru/ubuntu/947841/start-autossh-on-system-startup
# http://rus-linux.net/MyLDP/sec/reverse-SSH-tunnel.html
# https://habr.com/ru/post/331348/

# -fN флаг для работы в фоне

# проверка настройки обратного ssh
# relay-server
sudo netstat -nap | grep 2022

# Автоподключение

# контроль ssh туннеля
# -fN флаг для работы в фоне
autossh -M 2021 \
  -o "PubkeyAuthentication=yes" \
  -o "StrictHostKeyChecking=false" \
  -o "PasswordAuthentication=no" \
  -o "ServerAliveInterval 60" \
  -o "ServerAliveCountMax 3" \
  -R 2022:localhost:22 root@89.223.122.250

#-------

df -hT

sudo sshfs -o allow_other, IdentityFile = ~/.ssh/id_rsa sedicomm@x.x.x.x:/home/sedicomm/ /mnt/sedicomm
sudo sshfs -o allow_other \
  -p 2022 remote@localhost:/mnt/usb_500/_make_cloud_torrent_  /home/centos/dev/downloads


#-------------

autossh -M 0 -fN \
  -o "PubkeyAuthentication=yes" \
  -o "StrictHostKeyChecking=false" \
  -o "PasswordAuthentication=no" \
  -o "ServerAliveInterval 60" \
  -o "ServerAliveCountMax 3" \
  -R 46771:localhost:22 rr4
