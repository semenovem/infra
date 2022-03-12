[official site raspberry pi](https://www.raspberrypi.org)

application for iOS
https://itunes.apple.com/ru/app/vnc-viewer/id352019548?mt=8


remote connection - article
http://dmitrysnotes.ru/raspberry-pi-3-udalennoe-upravlenie-cherez-ssh-i-vnc

http://dmitrysnotes.ru/raspberry-pi-3-obzor-i-nachalo-raboty


# default
# user: pi
# pass: raspberry

sudo apt update
sudo apt dist-upgrade
sudo apt clean

sudo apt-get install git-core
sudo apt install libraspberrypi-bin

# режим настроек
sudo raspi-config

#temperature
vcgencmd measure_temp


# printer (didn't do)
apt-get install printer-driver-all

# 
sudo raspi-config

# vnc server, but it seems to come pre-configured
sudo apt-get update
sudo apt-get install realvnc-vnc-server
vncserver :1
