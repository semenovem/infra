#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1
. "${ROOT}/../../_lib/role.sh" || exit 1

# Получить name роли по id
get_role_name_by_id() {
  search=$1
  [ -z "$search" ] && search=0
  id=0

  for name in $__CORE_ROLES__; do
    id=$((id + 1))
    [ "$id" -eq "$search" ] && echo "$name" && return 0
  done

  return 1
}

# Отрисовка меню
draw_menu() {
  echo "--- Роли серверов и рабочих станций:"
  id=0

  while true; do
    id=$((id + 1))
    name=$(get_role_name_by_id "$id") || break
    echo "${id}. ${name}"
  done
}

# Выбор роли
main() {
  role=

  draw_menu
  read -rp "Номер роли. [q для выхода]: " ans

  case "$ans" in
  "1" | "2" | "3" | "4" | "5" | "6")
    role=$(get_role_name_by_id "$ans")
    [ $? -ne 0 ] && echo "нет такого id '$ans'" && return 1
    ;;

  *)
    echo "--- Отмена"
    return 1
    ;;
  esac

  echo "выбрана роль = '$role'"

  __confirm__
  [ $? -ne 0 ] && echo "--- Отмена записи выбранной роли" && return 0

  [ -n "$role" ] &&
    echo "--- Сохранение роли '$role' ..." &&
    __core_role_save__ "$role"
}

main
