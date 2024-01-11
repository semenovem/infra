#!/bin/sh

# Константы определяются в core.sh
[ -z "$__CORE_LOCAL_DIR__" ] && echo "Не установлена константа [__CORE_LOCAL_DIR__]" && exit 1

# Типы ролей
# при добавлении новой роли - также добавь и в __CORE_ROLES__
__CORE_ROLE_HOME_SERVER_CONST__="HOME_SERVER"
__CORE_ROLE_STANDBY_SERVER_CONST__="STANDBY_SERVER"
__CORE_ROLE_PROXY_SERVER_CONST__="PROXY_SERVER"
__CORE_ROLE_WORKSTATION_CONST__="WORKSTATION"
__CORE_ROLE_MINI_SERVER_CONST__="MINI_SERVER"
__CORE_ROLE_OFFICE_SERVER_CONST__="OFFICE_SERVER"

__CORE_ROLES__="$__CORE_ROLE_HOME_SERVER_CONST__"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_STANDBY_SERVER_CONST__}"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_PROXY_SERVER_CONST__}"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_WORKSTATION_CONST__}"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_MINI_SERVER_CONST__}"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_OFFICE_SERVER_CONST__}"

# Получение сохраненной роли устройства
__core_role_get__() {
  [ ! -f "${__CORE_LOCAL_DIR__}/role" ] && return 1
  role=$(cat "${__CORE_LOCAL_DIR__}/role")

  [ -z "$role" ] && return 1
  for it in $__CORE_ROLES__; do
    [ "$it" = "$role" ] && echo "$role" && return 0
  done
  return 1
}

# Сохранить роль
__core_role_save__() {
  role=$1
  [ -z "$role" ] && echo "не передано значение роли" >&2 && return 1

  echo "$role" >"${__CORE_LOCAL_DIR__}/role"
}
