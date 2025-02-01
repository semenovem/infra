#!/bin/sh


DST="/home/evg/tmp/star05"

for file in ./*.mkv; do
  echo "$file" | grep S05 -q || continue
  echo ">>> $file"

  docker run \
    -v "${PWD}:/app" \
    -v "${DST}:/resized" \
    -w /app jrottenberg/ffmpeg:7-scratch \
    -i "$file" \
    -c:a copy -c:v libx264 -hide_banner -loglevel error \
    -preset slow -crf 21 "/resized/${file}"

done

exit


#ffmpeg  -i 'StarGate.SG-1.S02E17 [BDRemux].mkv' -c:a copy -c:v libx264 -preset slow -crf 21 'StarGate.SG-1.S02E17.mkv'
#ffmpeg -i input_file_with_aac_audio.mp4 -c:a copy aac.aac


file="StarGate.SG-1.S04E01 [BDRemux].mkv"
file="StarGate.SG-1.S04E13 [BDRemux].mkv"

mkdir -p 'resized'

#docker run -v "${PWD}:/app" --cpus="2" -w /app jrottenberg/ffmpeg:7-scratch \
docker run -v "${PWD}:/app" -w /app jrottenberg/ffmpeg:7-scratch \
  -i "$file" \
  -c:a copy -c:v libx264 -hide_banner -loglevel error \
  -preset slow -crf 21 "resized/${file}"

#  -c:a copy -c:v libx264 -threads 2 -hide_banner -loglevel error \

exit


mkdir -p 'resized'

for file in ./*.mkv; do
  echo ">>> $file"

  docker run -v "${PWD}:/app" --cpus="2" -w /app jrottenberg/ffmpeg:7-scratch \
    -i "$file" \
    -vf scale=480:-1 \
    -map 0:v -map 0:5 -map 0:1 -map 0:8 \
    -disposition:a:0 default \
    "resized/${file}"

#    -threads 1 \

#  docker run -v "${PWD}:/app" --cpus="2" -w /app jrottenberg/ffmpeg:7-scratch \
#    -i "$file" \
#    -vf scale=480:-1 \
#    -map 0:v -map 0:a \
#    -threads 1 \
#    "resized/${file}"

    sleep 10
done

exit

 docker run -v $(pwd):/app -w /app jrottenberg/ffmpeg:7-scratch \
        -stats \
        -i S06E01.mkv \
        -vf scale=480:-1 \
        S06E01_480.mkv

ffmpeg \
-i /Users/sem/_infra/bin/.video-futurama/Futurama06/S06E01.mkv \
-vf scale=480:-1 \
/Users/sem/_infra/bin/.video-futurama/Futurama06/S06E01_480.mkv

exit


/Users/sem/_infra/bin/.video-futurama/Futurama06/S06E01.mkv

 docker run -v $(pwd):$(pwd) -w $(pwd) jrottenberg/ffmpeg:3.4-scratch \
        -stats \
        -i http://www.jell.yfish.us/media/jellyfish-20-mbps-hd-hevc-10bit.mkv \
        -c:v libx265 -pix_fmt yuv420p10 \
        -t 5 -f mp4 test.mp4
