
apt-get -y install autossh

# /etc/ssh/sshd_config
PasswordAuthentication no
PermitRootLogin no
AllowTcpForwarding yes