#!/bin/bash

echo "START"

dnf update -y
dnf install -y vim


echo \
"############################################################
# Set the value:                                            #
# PasswordAuthentication no                                 #
############################################################"

read -rsn 1 -p "Are you sure you want to continue? [y/N]" answer; echo
if [[ ${answer,,} != y ]]; then exit; fi


# для docker образа
dnf install -y openssh-server

vim /etc/ssh/sshd_config

echo ">>>>>>>>>>> "





