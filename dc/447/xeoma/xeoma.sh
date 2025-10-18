#!/bin/bash

docker run -it --rm --net=host -w /xeoma \
    -v "/etc/passwd:/etc/passwd:ro" \
    -v "/etc/group:/etc/group:ro" \
    -v "/mnt/vol1/xeoma:/xeoma" \
    -v "/mnt/vol1/xeoma/app:/app" \
    -u "$(id -u):$(id -g)" \
    xeoma:1.0 bash
