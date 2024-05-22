#!/bin/bash

#ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")

CMD="${__INFRA_BIN__}/util/backup/git-dirs.sh"
BACKUP_OFFICE=/mnt/md1/backup/ibtv-8
#BACKUP_HOME=/mnt/md1/backup/ibtv-8

#sh "${__INFRA_BIN__}/util/backup/git-dirs.sh" \
#  home /Volumes/dat/dion /mnt/soft/backup/ibtv-8/dion/05-21 2
#
#sh "${__INFRA_BIN__}/util/backup/git-dirs.sh" \
#  home /Volumes/dat/_dev /mnt/soft/backup/ibtv-8/dev/05-21 2


#
#sh "$CMD" \
#  office /Volumes/dat/_proj_archive "${BACKUP_OFFICE}/_proj_archive/05-22" 2
