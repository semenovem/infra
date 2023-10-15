#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

cp "${ROOT}/index.html" "/home/evg/media" || exit 1

docker run -d --restart on-failure:10 --name "screen-saver-fish" -p "8888:80" \
  -v "/home/evg/media:/usr/share/nginx/html:ro" \
  nginx:1.25.2
