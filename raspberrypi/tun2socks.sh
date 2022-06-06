#!/bin/bash
exit

# https://habr.com/ru/post/584162/

sudo /usr/sbin/tun2socks-linux-arm64 -device \
  tun://gatewaytun -proxy socks5://172.0.0.1:1080 \
  -loglevel warning \
sleep 3 \
sudo ip addr add 127.254.254.1/32 dev gatewaytun; \
sudo ip link set gatewaytun up; \
sudo ip route add default dev gatewaytun metric 50


#sudo ip route delete default dev gatewaytun

sudo vim /etc/systemd/system/tun2socks.service
```
[Unit]
Description=Tun2Socks gateway
After=network.target

[Service]
User=root
Type=idle
ExecStart=/usr/sbin/tun2socks-linux-arm64 -device tun://gatewaytun -proxy socks5://172.0.0.1:1080
#ExecStart=/usr/sbin/tun2socks-linux-arm64 -device tun://gatewaytun -proxy socks5://172.0.0.1:1080 & sleep 3; ip link set gatewaytun up
Restart=on-failure

[Install]
WantedBy=multi-user.target
```


sudo vim /etc/network/interfaces
sudo vim /etc/network/interfaces.d/gatewaytun
```
allow-hotplug gatewaytun
iface gatewaytun inet static
address 127.254.254.0
netmask 255.255.255.255
post-up ip route add default dev gatewaytun metric 50
```


systemctl start tun2socks
systemctl stop tun2socks

systemctl enable tun2socks

