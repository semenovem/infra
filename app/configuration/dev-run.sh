#!/bin/sh

CFG_ARG="-config-file=../../configs/main.yml"


go run -ldflags="-X 'main.appVersion=1.0.1'" *.go \
  ssh-remote-forward "$CFG_ARG" -host srv1


exit 0

  verify "$CFG_ARG"
  ssh-authorized-keys "$CFG_ARG" -role MINI_SERVer

