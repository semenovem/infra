#!/bin/zsh

# for macos
__VERSION__="1.0"
__DIR__="$(dirname $0)"

source "${__DIR__}/rc.sh"

# TODO - make a comparison on the added functions and show them, so as not to write by hand
function help() {
  echo "ver:${__VERSION__} [help, hldg, vtb_local_ip, cert, cert-req, myip]"
}

__resource__ "${__DIR__:?}/common"
__resource__ "${__DIR__:?}/macos"

help

unset __DIR__ __VERSION__ __resource__
