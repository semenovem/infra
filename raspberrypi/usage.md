
# default
# user: pi
# pass: raspberry

sudo apt update
sudo apt dist-upgrade
sudo apt clean
sudo reboot
sudo apt-get install git-core
sudo apt install libraspberrypi-bin

# режим настроек
sudo raspi-config

#temperature
vcgencmd measure_temp


# show ip address
hostname -i


# setting of host name
hostname [new name]


# change name of host for persistently
sudo vim /etc/hostname


# printer (didn't do)
apt-get install printer-driver-all

dc:a6:32:a2:4a:53
