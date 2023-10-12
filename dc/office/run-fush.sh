#!/bin/bash

docker run -d --name "screen-saver-fish" -p "8888:80" \
  -v "/home/evg/media:/usr/share/nginx/html:ro" \
  nginx:1.25.2
