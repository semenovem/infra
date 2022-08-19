#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
source "${ROOT}/../_core/conf.sh"
source "${ROOT}/../_core/role.sh"


# Получить name роли по id
get_role_name_by_id() {
  search=$1
  [ -z "$search" ] && search=0
  id=0

  for name in $__CORE_ROLES__; do
    [ "$((id++))" -eq "$search" ] && echo "$name" && return 0
  done

  return 1
}

draw_menu() {
  echo "--- Роли серверов и рабочих станций:"
  id=0

  while true; do
    ((id++))
    name=$(get_role_name_by_id "$id") || break
    echo "${id}. ${name}"
  done
}

main() {
  name=

  while true; do
    draw_menu
    read -rn 1 -p "Номер роли. [q для выхода]: " ans
    echo
    [ -n "$ans" ] && echo

    case "$ans" in
    "q" | "Q" | "n" | "N" | "^[")
      echo "--- Отмена"
      return 0
      ;;
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9")
      name=$(get_role_name_by_id "$ans") && break
      echo "нет такого id '$ans'"
      ;;
    esac

    sleep 1
  done

  echo "выбрана роль name = '$name'"
}

#main

#echo ">>> HOME = $HOME"


__core_role_save__

