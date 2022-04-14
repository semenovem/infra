
# routing setup
#https://www.dmosk.ru/miniinstruktions.php?mini=router-centos

# vpn setup
#https://www.dmosk.ru/instruktions.php?object=openvpn-centos-install

exit

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
firewall-cmd --get-zones
firewall-cmd --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-port 8080/tcp
firewall-cmd --reload


#------------------------
#------------------------
#------------------------

# for docker centos:centos8

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*

dnf install centos-release-stream -y
dnf swap centos-{linux,stream}-repos -y
dnf distro-sync -y
