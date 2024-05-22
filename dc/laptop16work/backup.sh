#!/bin/bash

TARGET=/mnt/md1/backup/laptop16work/


sh "${__INFRA_BIN__}/util/backup/git-dirs.sh" \
  office-local /Volumes/dat/dion "${TARGET}/dion/05-22" 2

sh "${__INFRA_BIN__}/util/backup/git-dirs.sh" \
  office-local /Volumes/dat/_dev "${TARGET}/dev/05-22" 2

