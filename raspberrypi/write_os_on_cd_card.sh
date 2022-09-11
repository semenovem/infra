
diskutil list

exit 0

diskutil unmountDisk /dev/disk4

sudo newfs_msdos -F 32 /dev/disk4

# ~/Downloads/2018-10-09-raspbian-stretch-lite.img path to image
sudo dd status=progress if=rasbp.img of=/dev/disk4

# ctr + t - show status
# wait about ~15-30 min

sudo diskutil eject /dev/disk4


#----- shrink of image
# https://github.com/Drewsif/PiShrink
