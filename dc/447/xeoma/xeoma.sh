#!/bin/bash

docker run -it --rm --net=host -w /xeoma \
    -v "/etc/passwd:/etc/passwd:ro" \
    -v "/etc/group:/etc/group:ro" \
    -v "/mnt/vol1/xeoma:/xeoma" \
    -v "/mnt/vol1/xeoma/app:/app" \
    ubuntu:24.04 bash
    # xeoma:1.0 bash

    # -u "$(id -u):$(id -g)" \
