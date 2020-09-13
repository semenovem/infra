#!/usr/bin/env bash

# trouble with ssh at Debian
apt-get install openssh-server
service ssh start
# and need create user for access at ssh


#-------
# SSH: Run Commands or Scripts Remotely
# https://www.shellhacks.com/ru/ssh-execute-remote-command-script-linux/

ssh root@192.168.1.1 'uptime'
ssh root@192.168.1.1 'reboot'


ssh root@192.168.1.1 'uptime; df -h'
ssh root@192.168.1.1 'free -m | cat /proc/loadavg'


ssh root@192.168.1.1 << EOF
  uname -a
  lscpu  | grep "^CPU(s)"
  grep -i memtotal /proc/meminfo
EOF

ssh root@192.168.1.1 'bash -s' < script.sh

