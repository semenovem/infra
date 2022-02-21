#!/bin/bash


ssh -R 2022:localhost:22 makecloud

autossh -M 0 -fN \
  -o "PubkeyAuthentication=yes" \
  -o "StrictHostKeyChecking=false" \
  -o "PasswordAuthentication=no" \
  -o "ServerAliveInterval 60" \
  -o "ServerAliveCountMax 3" \
  -R 2022:localhost:22 makecloud


# --------------------
# авто перезапуск ssh

sudo vim /etc/systemd/system/autossh-tunnel.service

[Unit]
Description = AutoSSH tunnel service
After       = network.target network-online.target

[Service]
Type        = simple
User        = evg
Group       = evg
Environment = "AUTOSSH_GATETIME=0"
Environment = "AUTOSSH_PORT=0"
Environment = "AUTOSSH_LOGFILE=/home/evg/logs/systemctl-autossh/ru.logs"
Environment = "AUTOSSH_PIDFILE=/home/evg/logs/systemctl-autossh/ru.pid"
ExecStart = /usr/bin/autossh -M 0 \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3" \
    -o "PubkeyAuthentication=yes" \
    -o "StrictHostKeyChecking=false" \
    -o "PasswordAuthentication=no" \
    -fNR 2022:localhost:22 ru

Restart            = always
#StartLimitInterval = 60
RestartSec=60
StartLimitInterval=300
StartLimitBurst=3

[Install]
WantedBy = multi-user.target


sudo systemctl daemon-reload
sudo systemctl start autossh-tunnel.service
sudo systemctl enable autossh-tunnel.service
sudo systemctl status autossh-tunnel
