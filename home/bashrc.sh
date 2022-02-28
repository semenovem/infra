#!/bin/zsh

# Содержимое PEM сертификата
sx() {
  [ -z $1 ] && echo "передай аргумент $1" && return 1
  [ ! -f $1 ] && echo "Это не файл '$1'" && return 1
  openssl x509 -noout -text -in "$1"
}

#PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'

# source ~/_dev/environment/bash/image_magick

# todo doesn`t work on mac
# PS1="\e[0;36m\u@\h \W$ \e[m"
