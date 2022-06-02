#!/bin/bash

exit

# Список открытых портов
ss -ltupn

# Настройка разрешений на порт
sudo ufw allow from 192.168.33.0/24 to any port 5900

# открытый дескриптор директории
lsof | grep /Users/sem/mnt/srv1

# Используемые порты
sudo netstat -nap | grep 2022

sudo netstat -lntup
sudo lsof -i
sudo ss -lntu

# util control network
iptraf-ng

############################################################
############################################################

# find active computers in local host
nmap -sn 192.168.0.0/24

# find with ping
echo 192.168.1.{1..254}|xargs -n1 -P0 ping -c1|grep "bytes from"

--------
# show me ip
ipconfig getifaddr en0

# external ip - one of
curl ifconfig.me
curl ipecho.net/plain
