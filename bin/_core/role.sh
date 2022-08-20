#!/bin/sh

# Роль устройства
__CORE_ROLE__=

CORE_ROLE_PATH_DIR="${HOME}/_env_state"
CORE_ROLE_FILE="role"

# Типы ролей
# при добавлении новой роли - также добавь и в __CORE_ROLES__
__CORE_ROLE_UNDEFINED__="undefined"
__CORE_ROLE_HOME_SERVER_CONST__="HOME_SERVER"
__CORE_ROLE_STANDBY_SERVER_CONST__="STANDBY_SERVER"
__CORE_ROLE_PROXY_SERVER_CONST__="PROXY_SERVER"
__CORE_ROLE_WORK_STATION_CONST__="WORK_STATION"
__CORE_ROLE_MINI_SERVER_CONST__="MINI_SERVER"

__CORE_ROLES__="$__CORE_ROLE_HOME_SERVER_CONST__"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_STANDBY_SERVER_CONST__}"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_PROXY_SERVER_CONST__}"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_WORK_STATION_CONST__}"
__CORE_ROLES__="${__CORE_ROLES__} ${__CORE_ROLE_MINI_SERVER_CONST__}"

# Получение сохраненной роли устройства
if [ -f "${CORE_ROLE_PATH_DIR}/${CORE_ROLE_FILE}" ]; then
  __CORE_ROLE__=$(cat "${CORE_ROLE_PATH_DIR}/${CORE_ROLE_FILE}")
fi


# Сохранить роль
__core_role_save__() {
  role=$1
  [ -z "$role" ] && echo "не передано значение роли" && return 1

  if [ ! -d "$CORE_ROLE_PATH_DIR" ]; then
    mkdir -p "$CORE_ROLE_PATH_DIR" || return 1
  fi

  echo "$role" >"${CORE_ROLE_PATH_DIR}/${CORE_ROLE_FILE}"
}
