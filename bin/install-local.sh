#!/bin/sh

#
# стартоваая настройка
#

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/_core/conf.sh"
. "${ROOT}/_core/os.sh"
. "${ROOT}/_core/logger.sh"
. "${ROOT}/_core/role.sh"
. "${ROOT}/_core/func.sh"

USER_PROFILE_FILE=
BIN_DIRS="$ROOT"
TMP_FILE=$(mktemp)

gen_profile_with_bin_dirs() {
  out="$__CORE_CONF_PROFILE_BIN_DIRS_FILE__"
  echo "# Автогенерируемый файл bin директорий" >"$out"
  echo "" >>"$out"

  dirs=
  # shellcheck disable=SC2068
  for dir in $@; do
    echo "## $dir" >>"$out"
    __is_dir_added_to_path__ && continue
    [ -n "$dirs" ] && dirs="${dirs}:"
    dirs="${dirs}${dir}"
  done

  [ -n "$dirs" ] && dirs="${dirs}:${PATH}" || dirs="$PATH"

  # shellcheck disable=SC2129
  echo "" >>"$out"
  echo "export PATH=\"${dirs}\"" >>"$out"

  echo "" >>"$out"
  echo "## additional profile" >>"$out"
  echo "source ${ROOT}/../home/profile" >>"$out"

  echo "" >>"$out"
  echo "## repository update" >>"$out"
  echo "sh ${ROOT}/utils/update-repo.sh \"${ROOT}/utils\" &" >>"$out"
}

add_source_file_to_profile() {
  profileFile=$1
  oper=$2
  file=$3
  comment=$4

  grep -i "$file" "$profileFile" -q &&
    __debug__ "Путь к файлу '${file}' уже добавлен" &&
    return 0

  [ -n "$(tail -n1 "$profileFile")" ] && echo "" >>"$profileFile"

  # shellcheck disable=SC2129
  echo "## $comment" >>"$profileFile"
  echo "${oper} ${file}" >>"$profileFile"
  echo "" >>"$profileFile"

  __debug__ "Путь к файлу '${file}' добавлен"
}

# ----------------
# Выбрать роль устройства
sh "${ROOT}/utils/set-role.sh"
ROLE=$(__core_role_get__) || __warn__ "Не выбрана роль устройства"

case "$ROLE" in
"$__CORE_ROLE_MINI_SERVER_CONST__")
  BIN_DIRS="${BIN_DIRS} ${ROOT}/mini_server"
  ;;

"$__CORE_ROLE_PROXY_SERVER_CONST__")
  BIN_DIRS="${BIN_DIRS} ${ROOT}/proxy_server"
  ;;

"$__CORE_ROLE_HOME_SERVER_CONST__" | "$__CORE_ROLE_STANDBY_SERVER_CONST__")
  BIN_DIRS="${BIN_DIRS} ${ROOT}/home_server"
  ;;

esac

# ----------------
# Тип системы
case "$__CORE_OS_KIND__" in
"$__CORE_OS_KIND_MACOS_CONST__")
  USER_PROFILE_FILE="${HOME}/.zshrc"
  BIN_DIRS="${BIN_DIRS} ${ROOT}/macos"
  ;;

"$__CORE_OS_KIND_LINUX_CONST__")
  USER_PROFILE_FILE="${HOME}/.bashrc"
  BIN_DIRS="${BIN_DIRS} ${ROOT}/linux"
  ;;

*)
  __err__ "Не определен тип OS"$()
  exit 1
  ;;
esac

# ----------------
# Выполнение проверок

[ ! -f "$USER_PROFILE_FILE" ] &&
  __err__ "Файла профиля не существует '$profileFile'" &&
  exit 1

# ----------------
# Выполнение настроек

# shellcheck disable=SC2086
gen_profile_with_bin_dirs $BIN_DIRS

# добавление в profile PATH
add_source_file_to_profile \
  "$USER_PROFILE_FILE" \
  "source" \
  "${__CORE_CONF_PROFILE_BIN_DIRS_FILE__}" \
  "adding PATH paths to bin utilities" ||
  exit 1

exit 0

# ----------------
# копирование vimrc
VIMRC_FILE_SOURCE="${ROOT}/../home/vimrc"
VIMRC_FILE_TARGET="${HOME}/.vimrc"
__copy_if_need_file_to__ "$VIMRC_FILE_SOURCE" "$VIMRC_FILE_TARGET" >"$TMP_FILE" 2>&1
OUTPUT="Копирование vimrc: $(cat "$TMP_FILE")"
if [ $? -eq 0 ]; then
  __info__ "$OUTPUT"
else
  __err__ "$OUTPUT"
fi
