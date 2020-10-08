#!/bin/bash

read -rsn 1 -p "Are you sure you want to continue? [y/N]" answer; echo
if [[ ${answer,,} != y ]]; then exit; fi

#-----
