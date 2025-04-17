
sudo apt install minidlna
config is here: /etc/minidlna.conf

# /lib/systemd/system/minidlna.service
systemctl daemon-reload
sudo systemctl restart minidlna
sudo systemctl stop minidlna


/usr/sbin/minidlnad -f $CONFIGFILE -P /run/minidlna/minidlna.pid -S $DAEMON_OPTS


Если видим: "WARNING: Inotify max_user_watches [8192] is low.", 
необходимо увеличить число дескрипторов слежения inotify до 100 000.
 Для этого в файл /etc/sysctl.conf добавим строки:
#MiniDLNA warning fix
fs.inotify.max_user_watches = 100000
Вручную редактором:

sudo nano /etc/sysctl.conf

