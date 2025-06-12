

ffmpeg -i 'Peaky.Blinders.s02e03.BDRemux.1080i.Rus.Eng.mkv' -vf "scale=1920:1080" -c:v libx264 -crf 23 -c:a copy '/home/evg/tmp/_videos/Peaky.Blinders.s02e03.mkv';
