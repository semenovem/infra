#!/bin/bash

# Точка монтирования директории для всех для чтения
# Монтирование директории с паролем


sudo apt update
sudo apt install -y samba

/etc/samba/smb.conf


[public]
path = /media/adman
guest ok = yes
force user = nobody
browsable = yes
writable = no






testparm -s
sudo service smbd restart


