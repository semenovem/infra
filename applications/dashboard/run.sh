#!/bin/sh

if [ -z "$1" ]; then
  while true; do
    sh run.sh "run"
    sleep 1
  done
else
  go run *.go
fi
