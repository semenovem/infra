#!/bin/zsh

function chrome {
  open -a Google\ Chrome
}

if [ -z "$(which realpath)" ] || [ "$(which realpath | grep 'not found')" ]; then
  function realpath {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
  }
fi
