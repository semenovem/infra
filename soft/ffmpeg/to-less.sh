#!/bin/sh


# # avi в mkv формат
# DIR="/mnt/1gb_hdd_3_5/torrents/The.Walking.Dead.World.Beyond.S02.WEB-DLRip.LF"
# cd "$DIR"

# DST_DIR="/home/evg/tmp/The.Walking.Dead.World.Beyond.S02"

# for file in *; do
#   filename="${file%.*}"
#   new_name="${DST_DIR}/${filename}.mkv"

#   echo ">>>>> file = $file   >>> ${new_name}"

#   ffmpeg -fflags +genpts -i "$file" -c:v copy -c:a copy "$new_name"
# done

# exit

# ---------------- кодирование стар-гейтса

# cd '/mnt/1gb_hdd_3_5/torrents/StarGate SG-1 (Season 1-10) [BDRemux]'

# pipe() {
#   while read -r file; do

#   echo ">>>>> file = $file"

#   ffmpeg -i "$file" \
#     -c:a copy -c:v libx264 -threads 2 -hide_banner -loglevel error \
#     -preset slow -crf 21 "/mnt/md1/backups/star-gate-s03/${file}"

#   done
# }


# find . -type f -name "*S03*" | pipe

# exit 0

for file in "/mnt/single4g/torrents/StarGate SG-1 (Season 1-10) [BDRemux]/StarGate.SG-1.S10"*; do
  # echo "$file" | grep -q S04 || continue
  echo ">>>>> file = $file"

  ffmpeg -i "$file" \
    -c:a copy -c:v libx264 -hide_banner -loglevel error -threads 2 \
    -preset slow -crf 21 "/home/evg/tmp/star05/$(basename "$file")"

done

# ll | grep S03

# echo ">>>> /mnt/md1/backups/star-gate-s03 $1"
