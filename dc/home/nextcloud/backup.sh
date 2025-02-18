#!/bin/bash


# /home/evg/_infra/dc/home/nextcloud/backup.sh


# LOCAL_PATH="/mnt/md1/gitlab"
# TARGET_PATH="/mnt/vol_backup_1/backups_gitlab"

# MONTH=$(date +%m)
# DAY=$(date +%d)

# INCREMENT_DIR="${TARGET_PATH}/incr/${MONTH}/${DAY}"

# rsync -a --delete --log-file=/dev/stdout --inplace --backup --quiet \
#   --backup-dir="$INCREMENT_DIR" "$LOCAL_PATH" "$TARGET_PATH"



LOCAL_PATH="/mnt/raid4t_soft/nextcloud"
TARGET_PATH="/mnt/vol_backup_1/backups_nextcloud"

MONTH=$(date +%m)
DAY=$(date +%d)

INCREMENT_DIR="${TARGET_PATH}/incr/${MONTH}/${DAY}"

rsync -a --delete --log-file=/dev/stdout --inplace --backup --quiet \
  --backup-dir="$INCREMENT_DIR" "$LOCAL_PATH" "$TARGET_PATH"
