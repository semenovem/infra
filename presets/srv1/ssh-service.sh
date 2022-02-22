#!/bin/bash

BIN=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")
NUM=$(grep -n Unit] "$0" | tail -1 | grep -Eo '[0-9]+')

SERVICE="auto-sh"
FILE="/etc/systemd/system/${SERVICE}.service"
FILE=/tmp/sdfsf

sed -n "${NUM},100p" "$0" > "$FILE" || exit 1


exit

sudo systemctl daemon-reload
sudo systemctl start "${SERVICE}.service"
sudo systemctl enable "${SERVICE}.service"
sudo systemctl status "$SERVICE"


exit 0

[Unit]
Description = run sh script
After       = network.target network-online.target

[Service]
Type        = simple
User        = adm
Group       = adm
ExecStart = /usr/bin/autossh -M 0 \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3" \
    -o "PubkeyAuthentication=yes" \
    -o "StrictHostKeyChecking=false" \
    -o "PasswordAuthentication=no" \
    -fNR 2022:localhost:22 ru

#Restart            = always
##StartLimitInterval = 60
#RestartSec=60
#StartLimitInterval=300
#StartLimitBurst=3

[Install]
WantedBy = multi-user.target


