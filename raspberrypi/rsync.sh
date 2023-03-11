#!/bin/sh

rsync -azP --delete --exclude="virtualbox/" --exclude=".*DS_Store" --exclude="._*" \
  --progress /mnt/ext2t02/share backup-user@192.168.11.100:/mnt/hdd-2t/backup-mini-ext2t02

#-azh

#--progress

unison /mnt/ext2t02/share ssh://192.168.1.19//mnt/hdd-2t/backup-mini-ext2t02/share/media

#–bwlimit=10000
