#!/bin/bash



# content /etc/fstab:
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# 4Tb raid-mainboard
/dev/md125   /mnt/raid4t_hard  ext4  defaults  1 2

# 4Tb raid-linux-mdadm
/dev/md402   /mnt/raid4t_soft  ext4  defaults  1 2

# 1Tb raid-linux
/dev/md11    /mnt/raid1t_soft  ext4  defaults  1 2
