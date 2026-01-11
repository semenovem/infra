#!/bin/bash

# https://exiftool.org/index.html

CUR_DIR="$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")"

#docker pull perl:5.42.0-bookworm

DIR="....................."

docker run -it --rm -u "$(id -u):$(id -g)" \
  -e "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/app/Image-ExifTool-13.45" \
  -v "${CUR_DIR}/modify.sh:/app/modify.sh" \
  -v "${DIR}:/app/photos/:rw" \
  -w /app \
  exif-tool:1 bash

# export PS1='\W$ '

exit 0

rsync -rP \
	--delete /Volumes/dat/evg_photos/ 447:/mnt/vol1/photo-lib



DateTimeOriginal                : 2021:07:31 08:04:12
CreateDate                      : 2021:07:31 08:04:12

exiftool -DateTimeOriginal 5J5A7966.jpg
exiftool -overwrite_original -DateTimeOriginal="2021:06:24 12:00:00" 5J5A7966.jpg
exiftool -overwrite_original -AllDates="2021:06:24 12:00:00" photos
