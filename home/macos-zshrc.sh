#!/bin/bash

# for macos
_VERSION_="1.0"
_DIR_=$1

[ ! -d "$_DIR_" ] &&
  echo "[ERROR] directory '${_DIR_}' does not exist" >>"${HOME}/evg-logfile.logs"

function chrome() {
  open -a Google\ Chrome
}

if [ -z "$(which realpath)" ] || [ "$(which realpath | grep 'not found')" ]; then
  function realpath() {
      [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
  }
fi

for file in "${_DIR_}/macos"/*.sh; do
  # shellcheck disable=SC1090
  source "$file"
done

for file in "${_DIR_}/common"/*.sh; do
  # shellcheck disable=SC1090
  source "$file"
done

# TODO - сделать сравнение на добавленные функции и показать их, что бы не писать руками

function help() {
  echo "ver:${_VERSION_} [help,hldg,vtb_local_ip,cert,cert-req]"
}

help

unset _DIR_ _VERSION_ file
