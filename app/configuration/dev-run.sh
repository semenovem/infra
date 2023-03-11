#!/bin/sh

CFG_ARG="-config-file=../../configs/main.yml"

go run -ldflags="-X 'main.appVersion=1.0.1'" *.go \
  ssh-authorized-keys "$CFG_ARG" -role MINI_SERVer

exit 0


ssh-remote-forward "$CFG_ARG" -host home

verify "$CFG_ARG"
