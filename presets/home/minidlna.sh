#!/bin/bash


sudo apt install -y minidlna

/etc/minidlna.conf
/etc/default/minidlna


sudo systemctl restart minidlna
systemctl status minidlna

sudo ss -4lnp | grep minidlna

