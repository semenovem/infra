#!/bin/bash

exit 0
# https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units-ru

systemctl list-units --all --state=inactive

# Отображение файла модуля
systemctl cat atd.service

# Отображение зависимостей
systemctl list-dependencies sshd.service


# shown auto-launch for services
systemctl list-unit-files --state enabled
systemctl list-unit-files

# added setvice in auto-launch
sudo systemctl enable ssh
