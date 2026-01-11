#!/bin/bash

exit 0

# $1 - file name
# return 2021:07:31 08:04:12
# return 1 - if not match date-time
fn_extract() {
  local filename="$1"

  if [[ $filename =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})\ ([0-9]{2})-([0-9]{2})-([0-9]{2}).* ]]; then
      year=${BASH_REMATCH[1]}
      month=${BASH_REMATCH[2]}
      day=${BASH_REMATCH[3]}
      hour=${BASH_REMATCH[4]}
      minute=${BASH_REMATCH[5]}
      second=${BASH_REMATCH[6]}

      echo "${year}:${month}:${day} ${hour}:${minute}:${second}"
      return 0
  else
     return 1
  fi
}

for file in photos/*; do
  if ! date_time="$(fn_extract "$(basename "$file")")"; then
    echo "[WARN] not match file=${file}"
    continue
  fi

  orig="$(exiftool -DateTimeOriginal "$file")"

  [ -n "$orig" ] && continue

  echo ">>>> date_time=${date_time}   from file=${file}   orig=${orig}"

#  exiftool -overwrite_original -AllDates="$date_time" "$file"

#  break
done
