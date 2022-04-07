

exit

yum -y install epel-release

# squid proxy
yum -y update && yum -y install squid
systemctl start squid
systemctl enable squid
systemctl status squid

# sudo vim /etc/squid/squid.conf
# http_port 3128 transparent
# http_access allow all
# sudo systemctl restart squid

#
firewall-cmd --zone=public --add-port=55555/tcp --permanent
firewall-cmd --reload

# user-admin
adduser adman
usermod -aG wheel adman

# sudo without pass
visudo
adman ALL=(ALL) NOPASSWD: ALL


# firewalld
dnf install firewalld -y
systemctl start firewalld


firewall-cmd --permanent --list-all
firewall-cmd --get-services
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
