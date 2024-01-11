#!/bin/bash

exit 0

sudo apt-get install lm-sensors
sensors

# fix trouble of locales
localedef -i en_US -f UTF-8 en_US.UTF-8


# DNS lookup utility
dig evgio.com

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



######################
journalctl -b -p err
