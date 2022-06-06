#!/bin/bash

exit 0

sudo apt-get install lm-sensors
sensors

# fix trouble of locales
localedef -i en_US -f UTF-8 en_US.UTF-8


# DNS lookup utility
dig evgio.dev

############################################################
# qr code
tools/qrcode:1.0

docker run -it --rm -v $PWD:/app -w /app ubuntu/dev:22.04 bash

# create qr codes
apt -y install qrencode
qrencode -s 6 -l H -o "qr.png" "otpauth://totp/semenovem@gmail.com?secret=...........&issuer=LinkedIn"

# read qr codes
apt -y install zbar-tools
zbarimg qrcode.png --nodbus  -q

# ################################
# list hardware
lshw

# ################################
# network traffic monitor
vnstat -u -i eth0
vnstat  # show traffic

# ################################
# iperf
iperf -s      # server (5001) open port on firewall
iperf -c host # client

