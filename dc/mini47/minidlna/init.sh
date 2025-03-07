#!/bin/bash

sudo apt install minidlna
sudo systemctl restart minidlna


Если видим: "WARNING: Inotify max_user_watches [8192] is low.", 
необходимо увеличить число дескрипторов слежения inotify до 100 000.
 Для этого в файл /etc/sysctl.conf добавим строки:
#MiniDLNA warning fix
fs.inotify.max_user_watches = 100000
Вручную редактором:

sudo nano /etc/sysctl.conf

#  /etc/minidlna.conf