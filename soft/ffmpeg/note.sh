#!/bin/bash

# 4k to fullHD

SRC_DIR="/mnt/md1/for_resize_media/Peaky Blinders s03/"
DST_DIR="/home/evg/tmp/_videos/Peaky_Blinders03"

for ORIG_FILE in "${SRC_DIR}"*.mkv; do
  RESIZED_FILE="${DST_DIR}/$(basename "$ORIG_FILE")"

  echo ">>>>>>>>>>>>> name=$RESIZED_FILE"

  ffmpeg -i "$ORIG_FILE" \
    -vf "scale=1920:1080" -c:v libx264 -crf 23 -c:a copy -threads 4 \
    "$RESIZED_FILE"
done

exit 0
 