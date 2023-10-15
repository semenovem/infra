#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

docker run -d --restart on-failure:10 --name "screen-saver-fish" -p "8888:80" \
  -v "${ROOT}/index.html:/usr/share/nginx/html:ro" \
  nginx:1.25.2
