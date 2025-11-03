#!/bin/bash

docker run -it --rm --net=host -w /xeoma \
    -v "/etc/passwd:/etc/passwd:ro" \
    -v "/etc/group:/etc/group:ro" \
    -v "/mnt/vol1/xeoma:/xeoma" \
    -v "/mnt/vol1/xeoma/app:/app" \
    ubuntu:25.10 bash
    # xeoma:1.0 bash

exit 


docker run -it --rm --net=host -w /xeoma \
    -v "/etc/passwd:/etc/passwd:ro" \
    -v "/etc/group:/etc/group:ro" \
    -v "/mnt/vol1/xeoma:/xeoma" \
    -v "/mnt/vol1/xeoma/app:/app" \
    alpine:3.22.2 sh
    # xeoma:1.0 bash

    # -u "$(id -u):$(id -g)" \


# https://felenasoft.com/xeoma/downloads/latest/linux/xeoma_linux_arm8.tgz