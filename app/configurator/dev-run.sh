#!/bin/sh

CFG_ARG="-config-file=../../configs/main.yml"


go run -ldflags="-X 'main.appVersion=1.0.2'" *.go \
 pki "$CFG_ARG" -host eu1


#  ssh-remote-forward "$CFG_ARG" -host office-server


exit 0
  version


  ssh-authorized-keys "$CFG_ARG" -role OFFICE_SERVER


  verify "$CFG_ARG"

