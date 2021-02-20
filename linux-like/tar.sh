

exit

# https://losst.ru/arhivatsiya-v-linux

# create
tar -zcvf archive.tar.gz /path/to/files

# extract
tar -zxvf archive.tar.gz

# -----------------
# -----------------
# -----------------


#!/bin/bash

LS=$(ls)
for entry in $LS; do
  if [ ! -f $entry ]; then
    continue
  fi
  if [ "${entry: -3}" == ".sh" ]; then
    continue
  fi

  echo $entry

  zip -P 000000 "qqw/$entry.zip" $entry
done
