#!/bin/sh

if [ -z "$__THIS_IS_DOCKER_CONTAINER__" ]; then

  NET_NAME="envi-ip-dev"

  NET_ID=$(docker network ls -f "name=${NET_NAME}" -q) || exit 1
  if [ -z "$NET_ID" ]; then
    docker network create --attachable "$NET_NAME" || exit 1
    sleep 1
  fi

  docker run -it --rm \
    -u "$(id -u):$(id -g)" \
    -w /app \
    --network "$NET_NAME" \
    --hostname "ipecho-server" \
    -v "${PWD}:/app:rw" \
    -e "GOCACHE=/tmp" \
    -e "__THIS_IS_DOCKER_CONTAINER__=1" \
    -e "IP_ECHO_DEBUG=true" \
    -e "IP_ECHO_PORT=8080" \
    -p "6004:8080" \
    golang:1.20.7 bash

  exit $?
fi

go run /app/*.go -env /app/config.env
