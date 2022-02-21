#!/bin/bash


# --------------------
# авто перезапуск ssh

sudo vim /etc/systemd/system/autossh-tunnel-mgr.service

[Unit]
Description = AutoSSH tunnel service
#After       = network.target network-online.target
After       = network.target network-online.target sshd.service

[Service]
Type        = simple
User        = evg
Group       = evg
Environment = "AUTOSSH_GATETIME=0"
Environment = "AUTOSSH_PORT=0"
Environment = "AUTOSSH_LOGFILE=/home/evg/logs/systemctl-autossh/eu.logs"
Environment = "AUTOSSH_PIDFILE=/home/evg/logs/systemctl-autossh/eu.pid"
ExecStart = /usr/bin/autossh -M 0 \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3" \
    -o "PubkeyAuthentication=yes" \
    -o "StrictHostKeyChecking=false" \
    -o "PasswordAuthentication=no" \
    -fNR 2022:localhost:22 europe

#Restart            = always
#RestartSec         = 5
#TimeoutStartSec    = 1
#TimeoutStopSec     = 1
#StartLimitInterval = 60
Restart            = always
RestartSec=15
StartLimitInterval=300
StartLimitBurst=3

[Install]
WantedBy = multi-user.target


# [Service]
# ExecStop
# PIDFile=

# [Install]
# WantedBy = network-online.target


sudo systemctl daemon-reload
sudo systemctl start autossh-tunnel-europe.service
sudo systemctl enable autossh-tunnel-europe.service
sudo systemctl status autossh-tunnel-europe
