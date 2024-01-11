#!/bin/bash
exit 0

# file with rules
# ls -l /etc/iptables/

# list of rules
iptables -t nat -L -n -v
sudo iptables -t nat -D POSTROUTING 1

# restart service
/etc/init.d/networking restart

iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 33443
iptables -t nat -A PREROUTING -i wlan0 -p tcp  -j REDIRECT --to-port 33443

sudo iptables -t nat -A POSTROUTING -p tcp --dport 22 -o usb0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE

---

iptables -t nat -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
