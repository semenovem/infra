#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

sh "${ROOT}/../../bin/util/backup/git-dirs.sh" \
  home /Volumes/dat/_dev /mnt/soft/backup/laptop-16inno/13 1

#sh "${ROOT}/../../bin/util/backup/git-dirs.sh" \
#  home /Volumes/dat/dion /mnt/soft/backup/laptop-16inno/13 1
