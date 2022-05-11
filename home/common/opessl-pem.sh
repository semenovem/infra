#!/bin/bash

function cert() {
  local file=$1
  [ -z "$file" ] && echo "pass an argument ${file}" && return 1
  [ ! -f "$file" ] && echo "this is not a file '${file}'"  && return 1

  grep -q "BEGIN CERTIFICATE" "$file" \
    && (openssl x509 -noout -text -in "$1"; return $?)

  grep -q "BEGIN CERTIFICATE REQUEST" "$file" \
    && (openssl req -noout -text -in "$1"; return $?)
}
