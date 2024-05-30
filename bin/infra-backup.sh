#!/bin/sh


. "${__INFRA_BIN__}/_lib/core.sh" || exit 1

CFG_DIR="${__CORE_LOCAL_DIR__}/backup"
CFG_FILE="${CFG_DIR}/backup.conf"

if [ ! -d "$CFG_DIR" ]; then mkdir -p "$CFG_DIR" || exit 1; fi
if [ ! -f "$CFG_FILE" ]; then
  {
    echo "# file of config backup"
    echo "# example: laptop16work"
    echo "__SRC_NAME__=laptop16work"
    echo
    echo "# example: '/Volumes/dat/_proj /Volumes/dat/_dev'"
    echo "__BACKUP_FOR_OFFICE__=''"
    echo "__BACKUP_FOR_HOME__=''"
    echo
  } > "$CFG_FILE"
fi

. "${CFG_FILE}" || exit 1
MONTH_DAY=$(date +%m%d)

echo "[info] __SRC_NAME__          = ${__SRC_NAME__}"
echo "[info] __BACKUP_FOR_OFFICE__ = ${__BACKUP_FOR_OFFICE__}"
echo "[info] __BACKUP_FOR_HOME__   = ${__BACKUP_FOR_HOME__}"

__confirm__ "run backup ?" || exit 0

# $1 - список локальных директорий для резервного копирования
# $2 - ssh подключение user@host
# $3 - базовый путь для сохранения архива на удаленном сервере
func_backup_dirs () {
  for SRC_DIR in $1; do
    [ ! -d "$SRC_DIR" ] && __err__ "not a directory [${SRC_DIR}]" && continue
    REMOTE_DST="$3/$(basename "$SRC_DIR")/${MONTH_DAY}"

    __info__ ">>>> REMOTE_SERVER = $2"
    __info__ ">>>> SRC_DIR       = ${SRC_DIR}"
    __info__ ">>>> REMOTE_DST    = ${REMOTE_DST}"

    sh "${__INFRA_BIN__}/util/backup/git-dirs.sh" \
      "$2" \
      "$SRC_DIR" \
      "$REMOTE_DST" 2

  done
}


# TODO определить в какой сети находимся и выбрать оптимальное подключение
REMOTE_SERVER="office-local"
REMOTE_BASE_PATH="/mnt/md1/backup/laptop16work/archive"

# добавить периодичность полного копирования

func_backup_dirs "$__BACKUP_FOR_OFFICE__" "$REMOTE_SERVER" "$REMOTE_BASE_PATH"
