#!/bin/sh

#
# стартоваая настройка
#

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
BIN_DIR=$(dirname "$ROOT") || exit 1
BIN_DIR=$(dirname "$BIN_DIR") || exit 1
LIB_DIR="${BIN_DIR}/_lib"

[ ! -d "$BIN_DIR" ] && echo "[${BIN_DIR}] is not a directory" 1>&2 && exit 1
[ ! -d "$LIB_DIR" ] && echo "[${LIB_DIR}] is not a directory" 1>&2 && exit 1

. "${LIB_DIR}/core.sh" || exit 1
. "${LIB_DIR}/os.sh" || exit 1
. "${LIB_DIR}/role.sh" || exit 1

USER_PROFILE_FILE=
ADDITIONAL_BIN_DIRS=
TMP_FILE=$(mktemp)

gen_profile_with_bin_dirs() {
  envi_bin=$1
  shift

  echo "# Autogenerated file"
  echo
  echo "# bin directory:"

  dirs="\${__ENVI_BIN__}"
  echo "## $envi_bin"

  # shellcheck disable=SC2068
  for dir in $@; do
    echo "## ${envi_bin}/$dir"
    dirs="${dirs}:\${__ENVI_BIN__}/${dir}"
  done

  echo
  echo "export __ENVI_BIN__=\"${envi_bin}\""
  echo "export PATH=\"\${PATH}:${dirs}\""
  echo
  echo "## additional profile"
  echo "source \"\${__ENVI_BIN__}/../home/profile\""
  echo
  echo "## repository update"
  echo "sh \"\${__ENVI_BIN__}/utils/envi-sys/update-repo.sh\" \"${envi_bin}/utils/envi-sys\""
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

add_dirs() {
  ADDITIONAL_BIN_DIRS="${ADDITIONAL_BIN_DIRS} $*"
}

# ----------------
# Выбрать роль устройства
ROLE=$(__core_role_get__)
if [ $? -ne 0 ]; then
  sh "${BIN_DIR}/_utils/set-role.sh"
  ROLE=$(__core_role_get__)
  [ $? -ne 0 ] && __err__ "Не выбрана роль устройства" && exit 1
fi

case "$ROLE" in
"$__CORE_ROLE_MINI_SERVER_CONST__") add_dirs "roles/mini_server" ;;
"$__CORE_ROLE_PROXY_SERVER_CONST__") add_dirs "roles/proxy_server" ;;
"$__CORE_ROLE_HOME_SERVER_CONST__" | "$__CORE_ROLE_STANDBY_SERVER_CONST__") add_dirs "roles/home_server" ;;
"$__CORE_ROLE_WORKSTATION_CONST__") add_dirs "roles/workstation" ;;
esac

# ----------------
# Тип системы
case "$__CORE_OS_KIND__" in
"$__CORE_OS_KIND_MACOS_CONST__")
  USER_PROFILE_FILE="${HOME}/.zshrc"
  add_dirs "macos"
  ;;

"$__CORE_OS_KIND_LINUX_CONST__")
  USER_PROFILE_FILE="${HOME}/.bashrc"
  add_dirs "linux"
  ;;

*)
  __err__ "Не определен тип OS"
  exit 1
  ;;
esac

[ ! -f "$USER_PROFILE_FILE" ] &&
  __err__ "Файла профиля не существует '$USER_PROFILE_FILE'" &&
  exit 1

# shellcheck disable=SC2086
gen_profile_with_bin_dirs "$BIN_DIR" $ADDITIONAL_BIN_DIRS >"$CORE_PROFILE_FILE"

__info__ "CORE_PROFILE_FILE = $CORE_PROFILE_FILE"

# добавление в profile PATH
add_source_file_to_profile \
  "$USER_PROFILE_FILE" \
  "source" \
  "${CORE_PROFILE_FILE}" \
  "adding PATH paths to bin utilities" ||
  exit 1

# ----------------
# копирование vimrc
VIMRC_FILE_SOURCE="${BIN_DIR}/../configs/vimrc"
VIMRC_FILE_TARGET="${HOME}/.vimrc"
sh "${LIB_DIR}/copy_if_need_file_to.sh" "$VIMRC_FILE_SOURCE" "$VIMRC_FILE_TARGET" >"$TMP_FILE" 2>&1
OUTPUT="Копирование vimrc: $(cat "$TMP_FILE")"
if [ $? -eq 0 ]; then
  __info__ "$OUTPUT"
else
  __err__ "$OUTPUT"
fi
