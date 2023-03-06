#!/bin/sh

rsync -azP --delete --exclude="virtualbox/" --exclude=".*DS_Store" --exclude="._*" /mnt/ext2t02/share backup-user@192.168.11.100:/mnt/hdd-2t/backup-mini-ext2t02

#-azh

#--progress
