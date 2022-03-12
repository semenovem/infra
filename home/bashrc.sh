#!/bin/zsh

_VERSION_="1.0"
_DIR_=$1

for file in "${_DIR_}/common"/*.sh; do
  # shellcheck disable=SC1090
  source "$file"
done

function help() {
  echo "ver:${_VERSION_} [help,cert]"
}

help

unset file _DIR_ _VERSION_

#PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'

# source ~/_dev/environment/bash/image_magick

# todo doesn`t work on mac
# PS1="\e[0;36m\u@\h \W$ \e[m"
