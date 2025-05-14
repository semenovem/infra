#!/bin/bash

# https://selectel.ru/blog/tutorials/how-to-install-and-configure-3proxy-proxy-servers-on-ubuntu/

# /etc/3proxy/.proxyauth

if [ "$(id -u)" -ne 0 ]; then
    echo "[INFO] need run with sudo"
    sudo sh $0 
    exit 
fi

__USER_NAME__=proxy3
__SOSCK5_PORT__=1080

# Ubuntu
apt-get update && sudo apt-get install -y build-essential

# Centos
yum update && yum -y install gcc wget tar make 

if [ ! -f "0.9.5.tar.gz" ]; then
    wget https://github.com/z3APA3A/3proxy/archive/0.9.5.tar.gz || exit
fi


tar xzf 0.9.5.tar.gz || exit
(cd 3proxy-0.9.5 && make -f Makefile.Linux) 1>/dev/null || exit
mkdir -p /etc/3proxy
cp 3proxy-0.9.5/bin/3proxy /usr/bin/ || exit 


# for ubunty
adduser --system --no-create-home --disabled-login --group "$__USER_NAME__"
# for centos
useradd -s /usr/sbin/nologin -U -M -r "$__USER_NAME__" 

id "$__USER_NAME__" || exit

user_id="$(id -u "$__USER_NAME__")"
user_gid="$(id -g "$__USER_NAME__")"

echo "[INFO] user_id=$user_id"
echo "[INFO] user_gid=$user_gid"

# --------------------------------
cat <<EOF > /etc/3proxy/3proxy.cfg
setgid ${user_gid}
setuid ${user_id}

nserver 8.8.8.8
nserver 8.8.4.4

nscache 65536
timeouts 1 5 30 60 180 1800 15 60

users $/etc/3proxy/.proxyauth
# users user:CL:password

daemon
log /var/log/3proxy/3proxy.log D
logformat "- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T"
rotate 30

auth cache strong
maxconn 384
# proxy -n -p3128 -a
socks -n -a -p${__SOSCK5_PORT__}
EOF

#-----------------------------------
cat <<EOF > /etc/3proxy/.proxyauth
# Enter user data:
# user:CL:password
EOF

vim /etc/3proxy/.proxyauth

chmod 400 /etc/3proxy/.proxyauth
#-----------------------------------

chown proxy3:proxy3 -R /etc/3proxy
chown proxy3:proxy3 /usr/bin/3proxy
chmod 444 /etc/3proxy/3proxy.cfg

mkdir -p /var/log/3proxy
chown proxy3:proxy3 -R /var/log/3proxy



#----------------------------------- sysctemctl 
systemctl stop 3proxy

cat <<EOF > /etc/systemd/system/3proxy.service
[Unit]
Description=3proxy Proxy Server
After=network.target
[Service]
Type=simple
ExecStart=/usr/bin/3proxy /etc/3proxy/3proxy.cfg
ExecStop=/bin/kill `/usr/bin/pgrep -u proxy3`
RemainAfterExit=yes
Restart=on-failure
RestartSec=10s
[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
sudo systemctl start 3proxy
sleep 1
sudo systemctl status 3proxy

echo "[INFO] ----------------------------"
echo "[INFO] sudo systemctl start 3proxy"
echo "[INFO] sudo systemctl enable 3proxy"
echo "[INFO] sudo systemctl stop 3proxy"
echo "[INFO] sudo systemctl status 3proxy"
echo '[INFO] ps -ela | grep "3proxy"'
echo "[INFO] ----------------------------"

exit 0
