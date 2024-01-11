#!/bin/bash

exit 0

# диск в ram
mkdir /mnt/tmpfs/
chmod 777 /mnt/tmpfs/
sudo mount -t tmpfs -o size=xxxM tmpfs /mnt/tmpfs/

# изменение размера ramdisk
sudo mount -o remount -o size=yyyM /mnt/tmpfs/


############################################################
# davfs (для ya | mail дисков(
# https://help.ubuntu.ru/wiki/davfs2


############################################################
# du
# size of directories in `node_modules`
du -sh ./node_modules/* | sort -nr | grep '\dM.*'
# size of contents
du -hd 1 ./

############################################################
# find
# https://www.opennet.ru/docs/RUS/linux_base/node149.html

# find and `rm node_modules`
find ./* -type d -name "node_modules"
find ./* -type d -name "*dir*" | xargs rm -dfR

# count files
find ~/_dev/ -type f | wc -l
# by type of file
find . -type f -name "*.txt" | wc -l

# count directories
find . -type d | wc -l


# --------------------
# проверка smart данных дисков
sudo smartctl -a /dev/sda
