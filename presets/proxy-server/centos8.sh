#!/bin/bash

#docker run -it --rm -v $PWD:/app:rw -w /app centos:centos8 bash


sudo vim /etc/ssh/sshd_config

PasswordAuthentication yes
PasswordAuthentication no

systemctl restart sshd.service
