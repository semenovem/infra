
application for iOS
https://itunes.apple.com/ru/app/vnc-viewer/id352019548?mt=8


remote connection - article
http://dmitrysnotes.ru/raspberry-pi-3-udalennoe-upravlenie-cherez-ssh-i-vnc
http://dmitrysnotes.ru/raspberry-pi-3-obzor-i-nachalo-raboty


------------------------------------  
### wi-fi
# drivers for wifi dongles
https://github.com/aircrack-ng/rtl8812au
https://github.com/Mange/rtl8192eu-linux-driver

>> access point  
https://raspberrypi.ru/wireless_access_point
https://help.ubuntu.ru/wiki/wifi_ap
https://www.raspberrypi.com/documentation/computers/configuration.html

>> compatible adapters
https://elinux.org/RPi_USB_Wi-Fi_Adapters
  

> connect to wifi  
/etc/wpa_supplicant/wpa_supplicant.conf  


------------------------------------  
> режим настроек  
sudo raspi-config

> temperature  
vcgencmd measure_temp


# printer (didn't do)
apt install printer-driver-all

# vnc server, but it seems to come pre-configured
sudo apt install realvnc-vnc-server
vncserver :1


------------------------------------  
### bash 

sudo apt update && sudo apt -y dist-upgrade \
  && sudo apt -y install git-core libraspberrypi-bin realvnc-vnc-server


------------------------------------  
> mount fs ext4
// exfat-fuse exfat-utils
> https://www.maketecheasier.com/mount-access-ext4-partition-mac/
sudo ext4fuse /dev/disk3s1 ~/tmp/MY_DISK_PARTITION -o allow_other

