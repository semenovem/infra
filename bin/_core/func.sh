#!/bin/sh

__confirm__() {
  while true; do
    read -rp "Подтвердить ? [y/N]:" ans

    case $ans in
    "y" | "Y") return 0 ;;
    "" | "n" | "N") return 1 ;;
    esac
  done
}
