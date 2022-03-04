#!/bin/bash

exit

mkdir /mnt/tmpfs/
chmod 777 /mnt/tmpfs/
sudo mount -t tmpfs -o size=xxxM tmpfs /mnt/tmpfs/

# изменение размера ramdisk
sudo mount -o remount -o size=yyyM /mnt/tmpfs/


#----------------
# davfs
https://help.ubuntu.ru/wiki/davfs2
