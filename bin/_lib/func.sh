#!/bin/sh

__lib_platform__() {
  case "$(uname)" in
    'Linux')    echo 'LINUX' ;;
    'Darwin')       echo 'MACOS' ;;
  *) echo "UNKNOWN";;
  esac
}

#__core_os__() {
#  case $OS in
#    'Linux')    echo 'Linux' ;;
#    'Darwin')       echo 'Mac' ;;
#  *) echo "UNKNOWN";;
#  esac
#}
