#!/bin/sh

# каждый час
# crontab
# 1 * * * * sh /home/evg/_infra/dc/home/crone/xeoma-copy-to-ya-disk.sh >> ~/logs/xeoma-copy-to-ya-disk.log 2>&1

# $1 - path to file
# $2 - max size in bytes
# $3 - optional - number of files, default = 1
func_logs_maintain() {
  [ -f $1 ] || return 0
  size="$(stat --printf="%s" "$1")"
  [ "$size" -lt $2 ] && return 0

  ind="$3"
  [ -z "$ind" ] && ind=2
  ind=$((ind-1))
  if [ "$ind" -le "0" ]; then : > $1; return 0; fi

  prev_file=
  while [ "$ind" -ge "0" ]; do
    f="$1"
    [ "$ind" -ne "0" ] && f="${f}.${ind}"

    if [ -n "$prev_file" ] && [ -f "$f" ]; then
      mv "$f" "$prev_file"
    fi

    prev_file="$f"
    ind=$((ind-1))
  done
}

# 10485760
func_logs_maintain "${HOME}/logs/xeoma-last-video.log" 10485760

rsync -avzhHl --delete /mnt/xeoma-archive/ /mnt/vol_backup_1/ya-disk/xeoma-reut-archive
