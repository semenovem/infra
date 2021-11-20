#!/bin/bash

# https://1cloud.ru/help/network/nastroika-samba-v-lokalnoj-seti

# Точка монтирования директории для всех для чтения
# Монтирование директории с паролем


sudo apt-get update
sudo apt-get install -y samba
sudo cp /etc/samba/smb.conf{,.bak}  # копия файла настроек


#[public]
#path = /samba/public
#guest ok = yes
#force user = nobody
#browsable = yes
#writable = yes






testparm -s
service smbd restart


