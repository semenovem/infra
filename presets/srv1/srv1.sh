#!/bin/bash

exit 0



# назначение имени машины
sudo echo "srv1" > /etc/hostname


# Создание основного пользователя adm
sudo useradd -s /bin/bash -m -G sudo adm

# Создание remote
sudo useradd -s /bin/bash -m remote

# Удаление пользователя ubuntu
sudo userdel ubuntu



ssh -NR 3022:localhost:22 ru
