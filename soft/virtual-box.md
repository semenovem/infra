
> ubuntu 24.04
apt install build-essential dkms linux-headers-$(uname -r) bzip2 -y

> подключить образ дополнений (top menu item: devices)
sh /media/evg/VBox_GAs_7.1.6/autorun.sh


-----------
> desktop
sudo apt install ubuntu-desktop-minimal -y
sh /media/evg/VBox_GAs_7.1.6/autorun.sh







apt install slim
apt install ubuntu-desktop
reboot
apt-get remove --purge libreoffice*.*

docker run -d -p 8081:8081 -v /Users/esemenov/tmp:/downloads ghcr.io/alexta69/metube