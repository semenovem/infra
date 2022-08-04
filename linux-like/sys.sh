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

#################################################
#################################################

# https://habr.com/ru/company/selectel/blog/264731/

journalctl -b
journalctl -k
journalctl --list-boots
journalctl --since 10:00 --until "1 hour ago"

journalctl -u nginx.service
journalctl _PID=381

# help filters
man systemd.journal-fields

journalctl -p err -b
#  0 — EMERG
#  1 — ALERT
#  2 — CRIT
#  3 — ERR
#  4 — WARNING
#  5 — NOTICE
#  6 — INFO
#  7 —DEBUG

journalctl --no-pager
journalctl -f
journalctl --disk-usage

sudo journalctl --vacuum-size=100M
sudo journalctl --vacuum-time=1week

# /еtc/systemd/journald.conf
