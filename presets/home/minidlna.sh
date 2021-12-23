#!/bin/bash


sudo apt install -y minidlna

/etc/minidlna.conf
/etc/default/minidlna

# Путь к файлу, установленный в дефолтной конфигурации
/mnt/raid4t_soft/minidlna/minidlna.conf


sudo systemctl restart minidlna
systemctl status minidlna

sudo ss -4lnp | grep minidlna

