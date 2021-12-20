#!/bin/bash

# Точка монтирования директории для всех для чтения
# Монтирование директории с паролем


sudo apt-get update
sudo apt-get install -y samba

/etc/samba/smb.conf


#[public]
#path = /samba/public
#guest ok = yes
#force user = nobody
#browsable = yes
#writable = yes






testparm -s
sudo service smbd restart


