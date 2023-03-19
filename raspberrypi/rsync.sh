#!/bin/sh

rsync -azP --bwlimit=1000 --delete \
  --exclude="virtualbox/" --exclude=".*DS_Store" --exclude="._*" --exclude="*.!qB" \
  --progress /mnt/ext2t02/share backup-user@192.168.11.100:/mnt/hdd-2t/backup-mini-ext2t02

#-azh

#--progress

unison /mnt/ext2t02/share ssh://backup-user@192.168.11.100//mnt/hdd-2t/backup-mini-ext2t02
