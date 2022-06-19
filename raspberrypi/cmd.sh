#!/bin/bash

exit 0



sudo apt update && sudo apt full-upgrade -y
sudo apt-get install exfat-fuse exfat-utils


# https://www.maketecheasier.com/mount-access-ext4-partition-mac/

sudo ext4fuse /dev/disk3s1 ~/tmp/MY_DISK_PARTITION -o allow_other

# drivers for wifi dongles
https://github.com/aircrack-ng/rtl8812au

https://github.com/Mange/rtl8192eu-linux-driver

# wifi point
https://raspberrypi.ru/wireless_access_point
https://help.ubuntu.ru/wiki/wifi_ap
https://www.raspberrypi.com/documentation/computers/configuration.html