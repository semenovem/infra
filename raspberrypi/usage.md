
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
