diskutil list

exit 0

diskutil unmountDisk /dev/disk4

sudo newfs_msdos -F 32 /dev/disk4

# ~/Downloads/2018-10-09-raspbian-stretch-lite.img path to image
sudo dd status=progress if=rasbp.img of=/dev/disk4

# ctr + t - show status
# wait about ~15-30 min

sudo diskutil eject /dev/disk4

# ------------------------
# сжатие образа
# https://askubuntu.com/questions/1174487/re-size-the-img-for-smaller-sd-card-how-to-shrink-a-bootable-sd-card-image

sudo apt install gparted

sudo modprobe loop
sudo losetup -f
sudo losetup /dev/loop0 myimage.img
sudo partprobe /dev/loop0
sudo gparted /dev/loop0

sudo losetup -d /dev/loop0
fdisk -l myimage.img
truncate --size=$(((9181183 + 1) * 512)) myimage.img
