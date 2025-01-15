#!/bin/bash

# https://www.dmosk.ru/miniinstruktions.php?mini=mdadm
# http://xgu.ru/wiki/mdadm

# content /etc/fstab:
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/nvme0n1p2 during curtin installation
/dev/disk/by-uuid/f530ab37-6ae8-4cba-95ff-d22fd65b57e5 / ext4 defaults 0 1
# /boot/efi was on /dev/nvme0n1p1 during curtin installation
/dev/disk/by-uuid/7FC7-C98C /boot/efi vfat defaults 0 1
/swap.img	none	swap	sw	0	0

# 4Tb raid-mainboard
# /dev/md126    /mnt/raid4t_hard  ext4  defaults  0 0

# 4Tb raid-linux-mdadm
/dev/md402    /mnt/raid4t_soft  ext4  defaults  0 0

# 1Tb ssd raid-linux-mdadm
/dev/md1 /mnt/md1  ext4  defaults,nofail  1 0

# tmp ssd disk for any (/dev/sdf) 1t
# UUID=4af6e1b2-00be-4fde-8f03-43fa83b30fdf /mnt/tmp/ ext4 rw,users 0 0

# 1Tb hdd 3.5
UUID=c70d4195-fdfd-4119-a55b-1833f6ae5920  /mnt/1gb_hdd_3_5   ext4  defaults,nofail  1 0

# myramdisk  /tmp/ramdisk  tmpfs  defaults,size=1G,x-gvfs-show  0  0
tmpfs  /mnt/memfs  tmpfs  rw,size=1G  0   0

# details in the file ./init.txt
/usr/disk-img/disk-xeoma.ext3    /mnt/xeoma-archive ext3    defaults,loop  0 0


# --------------
# blkid
/dev/md402: UUID="a9650fe1-639c-44a6-b2ed-f69c679eecc7" BLOCK_SIZE="4096" TYPE="ext4"
/dev/nvme0n1p1: UUID="7FC7-C98C" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="06992e87-c81a-4091-a5c5-6682c65604e9"
/dev/nvme0n1p2: UUID="f530ab37-6ae8-4cba-95ff-d22fd65b57e5" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="195450b5-af3b-4579-88ea-196afd15d4b0"
/dev/sdd: UUID="364a96ca-f44c-4277-fa23-aa02bf2900d0" UUID_SUB="8b901d95-13d1-0294-93d9-36131e168ae6" LABEL="evg-srv:402" TYPE="linux_raid_member"
/dev/sdb: TYPE="isw_raid_member"
/dev/sdc: UUID="364a96ca-f44c-4277-fa23-aa02bf2900d0" UUID_SUB="bb791585-c015-0b95-4cbb-14bebccb66e0" LABEL="evg-srv:402" TYPE="linux_raid_member"
/dev/md126: LABEL="vol2" UUID="bbf60d65-c624-4caf-97b3-ce1a7292f51b" BLOCK_SIZE="4096" TYPE="ext4"
/dev/sda: TYPE="isw_raid_member"

