#!/bin/bash

# https://www.dmosk.ru/miniinstruktions.php?mini=mdadm
# http://xgu.ru/wiki/mdadm

# content /etc/fstab:
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/nvme0n1p2 during curtin installation
/dev/disk/by-uuid/f530ab37-6ae8-4cba-95ff-d22fd65b57e5 / ext4 defaults 0 1
# /boot/efi was on /dev/nvme0n1p1 during curtin installation
/dev/disk/by-uuid/7FC7-C98C /boot/efi vfat defaults 0 1
# /swap.img	none	swap	sw	0	0

# 4Tb raid-linux-mdadm
/dev/md402    /mnt/raid4t_soft  ext4  defaults  0 0

# 1Tb ssd raid-linux-mdadm
/dev/md1 /mnt/md1  ext4  defaults,nofail  1 0

# one hdd 4g - for backup
UUID=d87196f2-e471-4eda-948a-41bf60974a5a  /mnt/vol_backup_1  ext4  defaults,nofail  1 0

# /dev/sdb1 4g - media
UUID=0fce83b5-138a-496c-a044-4533412cf877  /mnt/vol_media_1  ext4  defaults,nofail  1 0

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
/dev/sdf: UUID="3f827d87-14f2-cb6d-f25c-c39f2f3c4b43" UUID_SUB="a611a243-e284-63de-cb21-e3ee801ba45a" LABEL="home:md1" TYPE="linux_raid_member"
/dev/nvme0n1p1: UUID="7FC7-C98C" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="06992e87-c81a-4091-a5c5-6682c65604e9"
/dev/nvme0n1p2: UUID="f530ab37-6ae8-4cba-95ff-d22fd65b57e5" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="195450b5-af3b-4579-88ea-196afd15d4b0"
/dev/sdd: UUID="364a96ca-f44c-4277-fa23-aa02bf2900d0" UUID_SUB="8b901d95-13d1-0294-93d9-36131e168ae6" LABEL="evg-srv:402" TYPE="linux_raid_member"
/dev/sdb1: LABEL="vol_backup_1" UUID="d87196f2-e471-4eda-948a-41bf60974a5a" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="249a2fe0-523d-d246-9071-b4b884564e9b"
/dev/sdg: UUID="c70d4195-fdfd-4119-a55b-1833f6ae5920" BLOCK_SIZE="4096" TYPE="ext4"
/dev/sde: UUID="3f827d87-14f2-cb6d-f25c-c39f2f3c4b43" UUID_SUB="d3ecca8e-31c9-e1b9-b44e-6c609e405ddd" LABEL="home:md1" TYPE="linux_raid_member"
/dev/sdc: UUID="364a96ca-f44c-4277-fa23-aa02bf2900d0" UUID_SUB="bb791585-c015-0b95-4cbb-14bebccb66e0" LABEL="evg-srv:402" TYPE="linux_raid_member"
/dev/md1: UUID="c02abef3-7c4c-458f-892c-67463d57fdc6" BLOCK_SIZE="4096" TYPE="ext4"
/dev/loop0: UUID="864911e9-ea39-4710-b3d9-0b037b94ce1e" BLOCK_SIZE="4096" TYPE="ext3"
/dev/loop5: TYPE="squashfs"
/dev/loop3: TYPE="squashfs"
/dev/sda1: LABEL="vol_media_1" UUID="0fce83b5-138a-496c-a044-4533412cf877" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="52e691e9-b47e-c149-8a82-b3364de02c7d"


# lsblk -f
NAME        FSTYPE            FSVER LABEL        UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0       ext3              1.0                864911e9-ea39-4710-b3d9-0b037b94ce1e   61.3G    32% /mnt/xeoma-archive
loop1       squashfs          4.0                                                           0   100% /snap/core20/2379
loop2       squashfs          4.0                                                           0   100% /snap/core20/2434
loop3       squashfs          4.0                                                           0   100% /snap/lxd/29351
loop4       squashfs          4.0                                                           0   100% /snap/lxd/31333
loop5       squashfs          4.0                                                           0   100% /snap/snapd/23258
loop6                                                                                       0   100% /snap/snapd/23545
sda
└─sda1      ext4              1.0   vol_media_1  0fce83b5-138a-496c-a044-4533412cf877    3.4T     0% /mnt/vol_media_1
sdb
└─sdb1      ext4              1.0   vol_backup_1 d87196f2-e471-4eda-948a-41bf60974a5a
sdc         linux_raid_member 1.2   evg-srv:402  364a96ca-f44c-4277-fa23-aa02bf2900d0
└─md402     ext4              1.0                a9650fe1-639c-44a6-b2ed-f69c679eecc7    2.3T    30% /mnt/raid4t_soft
sdd         linux_raid_member 1.2   evg-srv:402  364a96ca-f44c-4277-fa23-aa02bf2900d0
└─md402     ext4              1.0                a9650fe1-639c-44a6-b2ed-f69c679eecc7    2.3T    30% /mnt/raid4t_soft
sde         linux_raid_member 1.2   home:md1     3f827d87-14f2-cb6d-f25c-c39f2f3c4b43
└─md1       ext4              1.0                c02abef3-7c4c-458f-892c-67463d57fdc6  351.2G    57% /mnt/md1
sdf         linux_raid_member 1.2   home:md1     3f827d87-14f2-cb6d-f25c-c39f2f3c4b43
└─md1       ext4              1.0                c02abef3-7c4c-458f-892c-67463d57fdc6  351.2G    57% /mnt/md1
sdg         ext4              1.0                c70d4195-fdfd-4119-a55b-1833f6ae5920  587.8G    31% /mnt/1gb_hdd_3_5
nvme0n1
├─nvme0n1p1 vfat              FAT32              7FC7-C98C                                 1G     1% /boot/efi
└─nvme0n1p2 ext4              1.0                f530ab37-6ae8-4cba-95ff-d22fd65b57e5  375.9G    14% /

