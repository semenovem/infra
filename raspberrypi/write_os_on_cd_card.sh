#
# guide
# http://robot-on.ru/articles/formatirovanie-microsd-zagruzka-iso-macos-linux
#
#
# write image (*.dmg | *.img) at cd card for raspberry pi
# 2018-11-09
diskutil list

exit 0

#example path to drive - /dev/disk3

diskutil unmountDisk /dev/disk3

sudo newfs_msdos -F 32 /dev/disk3

# ~/Downloads/2018-10-09-raspbian-stretch-lite.img path to image
sudo dd if=~/Downloads/2018-10-09-raspbian-stretch-lite.img of=/dev/disk3
