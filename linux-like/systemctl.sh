#!/bin/bash

exit 0
# https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units-ru

systemctl list-units --all --state=inactive
systemctl list-unit-files

# Отображение файла модуля
systemctl cat atd.service

# Отображение зависимостей
systemctl list-dependencies sshd.service
