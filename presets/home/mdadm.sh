#!/bin/bash

# https://www.dmosk.ru/miniinstruktions.php?mini=mdadm#conf


/dev/md125
/dev/md126


/mnt/share    # Общее хранилище
/mnt/protect  # Ограниченный доступ

#
# vim /etc/fstab
/dev/md125   /mnt-share   ext4  defaults  1 2
/dev/md126   /mnt-protect   ext4  defaults  1 2

# sudo mount -a

