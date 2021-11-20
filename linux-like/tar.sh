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

#----------
# не работает при переносе между версиями macos | linux
# -a (-base64) создать данные с кодировкой base64
openssl enc -aes-256-cbc -iter 100000 -in source -out target
openssl enc -aes-256-cbc -d -iter 100000 -in source -out target

#-----------
gpg -c file
gpg --no-symkey-cache -o target.file  --decrypt source.file
