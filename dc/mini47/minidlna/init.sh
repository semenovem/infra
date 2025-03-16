#!/bin/bash

sudo apt install minidlna

mkdir -p /mnt/memfs/minidlna
chown minidlna:minidlna /mnt/memfs/minidlna

mkdir -p /mnt/hdd2t_media/caches/minidlna
sudo chown minidlna:minidlna /mnt/hdd2t_media/caches/minidlna

# /lib/systemd/system/minidlna.service
systemctl daemon-reload
sudo systemctl restart minidlna
sudo systemctl status minidlna


/usr/sbin/minidlnad -f $CONFIGFILE -P /run/minidlna/minidlna.pid -S $DAEMON_OPTS


Если видим: "WARNING: Inotify max_user_watches [8192] is low.", 
необходимо увеличить число дескрипторов слежения inotify до 100 000.
 Для этого в файл /etc/sysctl.conf добавим строки:
#MiniDLNA warning fix
fs.inotify.max_user_watches = 100000
Вручную редактором:

sudo nano /etc/sysctl.conf

#  /etc/minidlna.conf