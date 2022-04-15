#!/bin/bash

exit 0

#https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-centos-8
#https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-a-certificate-authority-ca-on-centos-8
#https://serveradmin.ru/nastroyka-openvpn-na-centos/
#https://www.dmosk.ru/miniinstruktions.php?mini=openvpn-centos8



sudo systemctl -f enable openvpn-server@server.service
sudo systemctl restart openvpn-server@server.service
sudo systemctl status openvpn-server@server.service
