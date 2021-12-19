#!/bin/zsh

# Содержимое PEM сертификата
sx() {
  [ -z $1 ] && echo "передай аргумент $1" && return 1
  [ ! -f $1 ] && echo "Это не файл '$1'" && return 1
  openssl x509 -noout -text -in "$1"
}
