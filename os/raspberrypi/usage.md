
remote connection - article
http://dmitrysnotes.ru/raspberry-pi-3-udalennoe-upravlenie-cherez-ssh-i-vnc
http://dmitrysnotes.ru/raspberry-pi-3-obzor-i-nachalo-raboty


------------------------------------  
##### wi-fi
>> compatible adapters
https://elinux.org/RPi_USB_Wi-Fi_Adapters

> drivers for wifi dongles
- https://github.com/aircrack-ng/rtl8812au  
- https://github.com/Mange/rtl8192eu-linux-driver
- https://github.com/lwfinger/rtl8188eu

iwconfig

--- 
ASUSTek Computer, Inc. 802.11ac NIC  
https://linux-hardware.org/?id=usb:0b05-1852

ASUS USB-AC53 Nano | RTL8812BU | EW-7822UNC  
https://github.com/cilynx/rtl88x2bu   
https://brainbucket.xyz/how-to-use-an-asus-usb-ac53-nano-on-a-raspberry-pi  

---
>> access point  
https://raspberrypi.ru/wireless_access_point
https://help.ubuntu.ru/wiki/wifi_ap
https://www.raspberrypi.com/documentation/computers/configuration.html
  

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


------------------------------------  
> отключить заставку и выключение экрана. Добавить строку в файл:
sudo vim /etc/lightdm/lightdm.conf
```
[SeatDefaults]
xserver-command=X -s 0 dpms
```

------------------------------------  
> посмотреть доступные сети
`sudo iwlist wlan0 scan | grep ESSID`


------------------------------------  
> air play
`https://github.com/FD-/RPiPlay`


