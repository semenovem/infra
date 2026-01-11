
# Backup
CODE=
BAK_DIR="/Volumes/m2t/immich-bak"
FILE_NAME="$(date +%Y%m%d)"

ssh evg@192.168.22.250 \
  'tar czvf - --exclude="./encoded-video" --exclude="./thumbs" -C "/mnt/vol1/immich" immich_data' \
  | openssl enc -aes-256-cbc -pbkdf2 -k "$CODE" \
  | split -b 900m -d - "${BAK_DIR}/${FILE_NAME}/${FILE_NAME}.tar."

count-objects --exclude encoded-video --exclude thumbs /mnt/vol1/immich/immich_data


# Unpack
CODE=
PATH_NAME="/Volumes/m2t/immich-bak/20260109/20260109.tar."
UNPACK_DIR="/Volumes/m2t/tmp/evg-11"
cat "${PATH_NAME}."* \
  | openssl enc -d -aes-256-cbc -pbkdf2 -k "$CODE" \
  | tar xvf - -C "$UNPACK_DIR"

