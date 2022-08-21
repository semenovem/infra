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

add_bin_dir_to_path() {
  echo "# Автогенерируемый файл bin директорий" >"$__CORE_CONF_PROFILE_BIN_DIRS_FILE__"
  echo "" >>"$__CORE_CONF_PROFILE_BIN_DIRS_FILE__"

  dirs=
  # shellcheck disable=SC2068
  for dir in $@; do
    echo "## $dir" >>"$__CORE_CONF_PROFILE_BIN_DIRS_FILE__"

    __is_dir_added_to_path__ && continue

    [ -n "$dirs" ] && dirs="${dirs}:"
    dirs="${dirs}${dir}"
  done

  [ -n "$dirs" ] && dirs="${dirs}:${PATH}" || dirs="$PATH"

  echo "" >>"$__CORE_CONF_PROFILE_BIN_DIRS_FILE__"
  echo "export PATH=\"${dirs}\"" >>"$__CORE_CONF_PROFILE_BIN_DIRS_FILE__"
}

add_source_file_to_profile() {
  profileFile=$1
  file=$2
  comment=$3

  [ ! -f "$profileFile" ] &&
    __err__ "Файла профиля не существует '$profileFile'" &&
    return 1

  grep -i "$file" "$profileFile" -q &&
    __debug__ "Путь к файлу '${file}' уже добавлен" &&
    return 0

  [ -n "$(tail -n1 "$profileFile")" ] && echo "" >>"$profileFile"

  # shellcheck disable=SC2129
  echo "## $comment" >>"$profileFile"
  echo "source ${file}" >>"$profileFile"
  echo "" >>"$profileFile"
}

# Выбрать роль устройства
sh "${ROOT}/utils/set-role.sh"
ROLE=$(__core_role_get__) || __warn__ "Не выбрана роль устройства"

USER_PROFILE_FILE=
BIN_DIRS="$ROOT"

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

# Роль
case "$ROLE" in
"$__CORE_ROLE_MINI_SERVER_CONST__")
  BIN_DIRS="${BIN_DIRS} ${ROOT}/hide-box"
  ;;
esac

add_source_file_to_profile \
  "$USER_PROFILE_FILE" \
  "${ROOT}/../home/profile" \
  "additional profile" ||
  exit 1

add_source_file_to_profile \
  "$USER_PROFILE_FILE" \
  "${__CORE_CONF_PROFILE_BIN_DIRS_FILE__}" \
  "adding PATH paths to bin utilities" ||
  exit 1

# shellcheck disable=SC2086
add_bin_dir_to_path $BIN_DIRS
