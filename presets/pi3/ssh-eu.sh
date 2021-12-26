#!/bin/bash


ssh -R 3022:localhost:22 europe

autossh -M 0 -fN \
  -o "PubkeyAuthentication=yes" \
  -o "StrictHostKeyChecking=false" \
  -o "PasswordAuthentication=no" \
  -o "ServerAliveInterval 60" \
  -o "ServerAliveCountMax 3" \
  -R 3022:localhost:22 europe


# --------------------
# авто перезапуск ssh

sudo vim /etc/systemd/system/autossh-tunnel-europe.service

[Unit]
Description = AutoSSH tunnel service
After       = network.target network-online.target

[Service]
Type        = simple
User        = evg
Group       = evg
Environment = "AUTOSSH_GATETIME=0"
ExecStart = /usr/bin/autossh -M 0 \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3" \
    -o "PubkeyAuthentication=yes" \
    -o "StrictHostKeyChecking=false" \
    -o "PasswordAuthentication=no" \
    -fNR 3022:localhost:22 europe

Restart            = always
StartLimitInterval = 0

[Install]
WantedBy = multi-user.target


sudo systemctl daemon-reload
sudo systemctl restart autossh-tunnel-europe.service
sudo systemctl enable autossh-tunnel-europe.service
sudo systemctl status autossh-tunnel-europe
