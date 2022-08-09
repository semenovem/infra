#!/bin/sh

BIN=$(dirname "$([ "$0" = "/*" ] && echo "$0" || echo "$PWD/${0#./}")")

echo ">>>>>>>>> ${BIN}"

if [ -n "$__SELF_OS_IS_UNIX__" ]; then
  sudo powermetrics | grep -i "CPU die temperature"
  return 0
fi

if [ -n "$__SELF_OS_IS_RASPBIAN__" ]; then
  watch -t -n 1 vcgencmd measure_temp
fi
