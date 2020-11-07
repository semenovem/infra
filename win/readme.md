


https://www.microsoft.com/ru-ru/software-download/windows10


# on macos 
diskutil list

# for example /dev/disk3
sudo diskutil eraseDisk FAT32 WININSTALL MBRFormat /dev/disk3

# mount iso

# copy to flash
cp -R iso usb
