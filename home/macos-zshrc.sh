#!/bin/bash

# for macos
_VERSION_="1.0"
_DIR_=$1

[ ! -d "$_DIR_" ] &&
  echo "[ERROR] directory '${_DIR_}' does not exist" >>"${HOME}/evg-logfile.logs"

function chrome() {
  open -a Google\ Chrome
}

for file in ${_DIR_}/macos/*.sh; do
  source "${_DIR_}/macos/hldg.sh"
done

for file in ${_DIR_}/common/*.sh; do
  source "${_DIR_}/macos/hldg.sh"
done

unset file

# TODO - сделать сравнение на добавленные функции и показать их, что бы не писать руками

function help() {
  echo "ver:${_VERSION_} [help,hldg,vtb_local_ip]"
}

help

if [ -z "$(which realpath)" ] || [ "$(which realpath | grep 'not found')" ]; then
  function realpath() {
      [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
  }
fi

unset _DIR_ _VERSION_
