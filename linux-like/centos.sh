

exit

sudo yum -y update && sudo yum -y install squid

sudo systemctl start squid
sudo systemctl enable squid
sudo systemctl status squid

# sudo vim /etc/squid/squid.conf
# http_port 3128 transparent
# http_access allow all
# sudo systemctl restart squid

#
firewall-cmd --zone=public --add-port=55555/tcp --permanent
firewall-cmd --reload
