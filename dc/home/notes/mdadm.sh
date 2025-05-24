# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/nvme0n1p2 during curtin installation
/dev/disk/by-uuid/f530ab37-6ae8-4cba-95ff-d22fd65b57e5 / ext4 defaults 0 1
# /boot/efi was on /dev/nvme0n1p1 during curtin installation
/dev/disk/by-uuid/7FC7-C98C /boot/efi vfat defaults 0 1
# /swap.img	none	swap	sw	0	0

# 4Tb raid-mainboard
# /dev/md126    /mnt/raid4t_hard  ext4  defaults,nofail  1 0

# 4Tb raid-linux-mdadm
/dev/md402    /mnt/raid4t_soft  ext4  defaults,nofail  1 0

# 1Tb ssd raid-linux-mdadm
/dev/md1 /mnt/md1  ext4  defaults,nofail  1 0

# one hdd 4g - single for backup
UUID=d87196f2-e471-4eda-948a-41bf60974a5a  /mnt/vol_backup_1	ext4  defaults,nofail  1 0

# /dev/sdb1 4g - media
UUID=0fce83b5-138a-496c-a044-4533412cf877  /mnt/vol_media_1	ext4  defaults,nofail  1 0

# 1Tb hdd 3.5
# UUID=c70d4195-fdfd-4119-a55b-1833f6ae5920  /mnt/1gb_hdd_3_5   ext4  defaults,nofail  1 0

# myramdisk  /tmp/ramdisk  tmpfs  defaults,size=1G,x-gvfs-show  0  0
tmpfs  /mnt/memfs  tmpfs  rw,size=1G  0   0

# xeoma disk
/usr/disk-img/disk-xeoma.ext4    /mnt/xeoma-archive ext4    defaults,loop  0 0


# https://cloud.evgio.com/remote.php/dav/files/evg/ /home/evg/nextcloud davfs sync,user,rw,noauto 0 0
http://127.0.0.1:7007/remote.php/dav/files/evg/ /home/evg/nextcloud davfs sync,user,rw,noauto 0 0


# xeoma to ya
/mnt/xeoma-archive/ /mnt/vol_backup_1/ya-disk/xeoma-reut-archive/ none bind 0 0



# --------------
# blkid
/dev/md402: UUID="a9650fe1-639c-44a6-b2ed-f69c679eecc7" BLOCK_SIZE="4096" TYPE="ext4"
/dev/sdf: UUID="3f827d87-14f2-cb6d-f25c-c39f2f3c4b43" UUID_SUB="a611a243-e284-63de-cb21-e3ee801ba45a" LABEL="home:md1" TYPE="linux_raid_member"
/dev/nvme0n1p1: UUID="7FC7-C98C" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="06992e87-c81a-4091-a5c5-6682c65604e9"
/dev/nvme0n1p2: UUID="f530ab37-6ae8-4cba-95ff-d22fd65b57e5" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="195450b5-af3b-4579-88ea-196afd15d4b0"
/dev/sdd: UUID="364a96ca-f44c-4277-fa23-aa02bf2900d0" UUID_SUB="8b901d95-13d1-0294-93d9-36131e168ae6" LABEL="evg-srv:402" TYPE="linux_raid_member"
/dev/sdb1: LABEL="vol_backup_1" UUID="d87196f2-e471-4eda-948a-41bf60974a5a" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="249a2fe0-523d-d246-9071-b4b884564e9b"
/dev/sde: UUID="3f827d87-14f2-cb6d-f25c-c39f2f3c4b43" UUID_SUB="d3ecca8e-31c9-e1b9-b44e-6c609e405ddd" LABEL="home:md1" TYPE="linux_raid_member"
/dev/sdc: UUID="364a96ca-f44c-4277-fa23-aa02bf2900d0" UUID_SUB="bb791585-c015-0b95-4cbb-14bebccb66e0" LABEL="evg-srv:402" TYPE="linux_raid_member"
/dev/sda1: LABEL="vol_media_1" UUID="0fce83b5-138a-496c-a044-4533412cf877" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="52e691e9-b47e-c149-8a82-b3364de02c7d"
/dev/md1: UUID="c02abef3-7c4c-458f-892c-67463d57fdc6" BLOCK_SIZE="4096" TYPE="ext4"


# lsblk -f
NAME        FSTYPE            FSVER LABEL        UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0       ext4              1.0                79ca6437-b94b-4df0-95d0-eeb71ffcf42a      1G    91% /mnt/vol_backup_1/ya-disk/xeoma-reut-archive
                                                                                                     /mnt/xeoma-archive
loop1                                                                                       0   100% /snap/snapd/24505
loop2
loop3                                                                                       0   100% /snap/lxd/29351
loop4                                                                                       0   100% /snap/lxd/31333
loop5                                                                                       0   100% /snap/core20/2571
loop6                                                                                       0   100% /snap/snapd/23771
loop7                                                                                       0   100% /snap/core20/2501
sda
└─sda1      ext4              1.0   vol_media_1  0fce83b5-138a-496c-a044-4533412cf877    2.2T    33% /mnt/vol_media_1
sdb
└─sdb1      ext4              1.0   vol_backup_1 d87196f2-e471-4eda-948a-41bf60974a5a    2.1T    37% /mnt/vol_backup_1
sdc         linux_raid_member 1.2   evg-srv:402  364a96ca-f44c-4277-fa23-aa02bf2900d0
└─md402     ext4              1.0                a9650fe1-639c-44a6-b2ed-f69c679eecc7    2.1T    37% /mnt/raid4t_soft
sdd         linux_raid_member 1.2   evg-srv:402  364a96ca-f44c-4277-fa23-aa02bf2900d0
└─md402     ext4              1.0                a9650fe1-639c-44a6-b2ed-f69c679eecc7    2.1T    37% /mnt/raid4t_soft
sde         linux_raid_member 1.2   home:md1     3f827d87-14f2-cb6d-f25c-c39f2f3c4b43
└─md1       ext4              1.0                c02abef3-7c4c-458f-892c-67463d57fdc6  841.6G     3% /mnt/md1
sdf         linux_raid_member 1.2   home:md1     3f827d87-14f2-cb6d-f25c-c39f2f3c4b43
└─md1       ext4              1.0                c02abef3-7c4c-458f-892c-67463d57fdc6  841.6G     3% /mnt/md1
nvme0n1
├─nvme0n1p1 vfat              FAT32              7FC7-C98C                                 1G     1% /boot/efi
└─nvme0n1p2 ext4              1.0                f530ab37-6ae8-4cba-95ff-d22fd65b57e5  374.4G    15% /

