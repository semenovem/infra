#!/bin/bash

function pem() {
  [ -z $1 ] && echo "pass an argument $1" && return 1
  [ ! -f $1 ] && echo "this is not a file '$1'"  && return 1

  openssl x509 -noout -text -in "$1"
}
