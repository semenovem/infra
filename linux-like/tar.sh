

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


# -------
# многотомный архив
7z a -v500m ../e/rez_first_cloud/arch.7z YandexDisk/

7z x ../../e/rez_first_cloud/arch.7z.001

