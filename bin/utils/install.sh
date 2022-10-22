#!/bin/sh

#
# стартоваая настройка
#

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
BIN_DIR=$(dirname "$ROOT") || exit 1

[ ! -d "$BIN_DIR" ] && echo "[${BIN_DIR}] is not a directory" 1>&2 && exit 1

. "${BIN_DIR}/_core/conf.sh" || exit 1
. "${BIN_DIR}/_core/os.sh"
. "${BIN_DIR}/_core/role.sh" || exit 1
. "${BIN_DIR}/_core/func.sh" || exit 1

USER_PROFILE_FILE=
ADDITIONAL_BIN_DIRS=
TMP_FILE=$(mktemp)

gen_profile_with_bin_dirs() {
  envi_bin=$1
  shift

  echo "# Autogenerated file"
  echo
  echo "# bin directory:"

  dirs="$envi_bin"
  echo "## $envi_bin"

  # shellcheck disable=SC2068
  for dir in $@; do
    echo "## ${envi_bin}/$dir"
    dirs="${dirs}:\${ENVI_BIN}/${dir}"
  done

  echo
  echo "ENVI_BIN=\"${envi_bin}\""
  echo
  echo "export PATH=\"\${PATH}:${dirs}\""

  echo
  echo "## additional profile"
  echo "source \"\${ENVI_BIN}/../home/profile\""

  echo
  echo "## repository update"
  echo "sh \"\${ENVI_BIN}/utils/update-repo.sh\" \"${envi_bin}/utils\""
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
ROLE=$(__core_role_get__)
if [ $? -ne 0 ]; then
  sh "${BIN_DIR}/utils/set-role.sh"
  ROLE=$(__core_role_get__)
  [ $? -ne 0 ] && __err__ "Не выбрана роль устройства" && exit 1
fi

case "$ROLE" in
"$__CORE_ROLE_MINI_SERVER_CONST__")
  ADDITIONAL_BIN_DIRS="${ADDITIONAL_BIN_DIRS} mini_server"
  ;;

"$__CORE_ROLE_PROXY_SERVER_CONST__")
  ADDITIONAL_BIN_DIRS="${ADDITIONAL_BIN_DIRS} proxy_server"
  ;;

"$__CORE_ROLE_HOME_SERVER_CONST__" | "$__CORE_ROLE_STANDBY_SERVER_CONST__")
  ADDITIONAL_BIN_DIRS="${ADDITIONAL_BIN_DIRS} home_server"
  ;;

"$__CORE_ROLE_WORKSTATION_CONST__")
  ADDITIONAL_BIN_DIRS="${ADDITIONAL_BIN_DIRS} workstation"
  ;;

esac

# ----------------
# Тип системы
case "$__CORE_OS_KIND__" in
"$__CORE_OS_KIND_MACOS_CONST__")
  USER_PROFILE_FILE="${HOME}/.zshrc"
  ADDITIONAL_BIN_DIRS="${ADDITIONAL_BIN_DIRS} macos"
  ;;

"$__CORE_OS_KIND_LINUX_CONST__")
  USER_PROFILE_FILE="${HOME}/.bashrc"
  ADDITIONAL_BIN_DIRS="${ADDITIONAL_BIN_DIRS} linux"
  ;;

*)
  __err__ "Не определен тип OS"
  exit 1
  ;;
esac

[ ! -f "$USER_PROFILE_FILE" ] &&
  __err__ "Файла профиля не существует '$profileFile'" &&
  exit 1

# shellcheck disable=SC2086
gen_profile_with_bin_dirs "$BIN_DIR" $ADDITIONAL_BIN_DIRS >"$__CORE_CONF_PROFILE_FILE__"

# добавление в profile PATH
add_source_file_to_profile \
  "$USER_PROFILE_FILE" \
  "source" \
  "${__CORE_CONF_PROFILE_FILE__}" \
  "adding PATH paths to bin utilities" ||
  exit 1

# ----------------
# копирование vimrc
VIMRC_FILE_SOURCE="${BIN_DIR}/../home/vimrc"
VIMRC_FILE_TARGET="${HOME}/.vimrc"
__copy_if_need_file_to__ "$VIMRC_FILE_SOURCE" "$VIMRC_FILE_TARGET" >"$TMP_FILE" 2>&1
OUTPUT="Копирование vimrc: $(cat "$TMP_FILE")"
if [ $? -eq 0 ]; then
  __info__ "$OUTPUT"
else
  __err__ "$OUTPUT"
fi