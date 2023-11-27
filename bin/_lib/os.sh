#!/bin/sh

#
# Определение OS
# $1 = hard вернуть macos / linux
#
HARD=$1

which uname >/dev/null
[ $? -ne 0 ] && echo "uname not found" >&2 && exit 1

uname -s | grep -iEq "^Darwin"
if [ $? -eq 0 ]; then
  OUT="macos"
  [ ! "$HARD" = "hard" ] && OUT="${OUT}-$(uname -m)"
  echo "$OUT"
  exit 0
fi

[ "$HARD" = "hard" ] && echo "linux" && exit 0

which "/usr/bin/raspi-config" >/dev/null
[ $? -eq 0 ] && echo "raspbian" && exit 0

which "apt" >/dev/null
[ $? -eq 0 ] && echo "debian" && exit 0

which "apt-get" >/dev/null
[ $? -eq 0 ] && echo "debian" && exit 0

which "rpm" >/dev/null
[ $? -eq 0 ] && echo "fedora" && exit 0

which "yum" >/dev/null
[ $? -eq 0 ] && echo "fedora" && exit 0
