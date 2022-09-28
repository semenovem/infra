#!/bin/sh

#
# Конфигурация
# -force
# -debug
# -yes
#

# Директория хранения данных. Есть копии в других файлах
__CORE_CONF_STATE_DIR__="${HOME}/_envi_state"

# Файл профиля
__CORE_CONF_PROFILE_FILE__="${HOME}/.profile_envi"

# Время последнего обновления репозитория
__CORE_CONF_LAST_UPDATE_REPO__="${__CORE_CONF_STATE_DIR__}/last-update-repo"

# отвечать утвердительно на запросы к пользователю
__YES__=

# дебаг режим. конфликтует с QUIET
__DEBUG__=

# тихий режим, не выводить сообщения. конфликтует с DEBUG
__QUIET__=

# выполнять действия без запроса подтверждения (например перезапись файлов)
__FORCE__=

# не производить изменений
__DRY__=

# вывод подсказки
__HELP__=

__SHORT__=

# файл содержит не обработанные аргументы командной строки
CORE_CONF_REST_ARGS_FILE=

# создать директорию данных окружения, если не существует
if [ ! -d "$__CORE_CONF_STATE_DIR__" ]; then
  mkdir "$__CORE_CONF_STATE_DIR__" || exit 1
fi

# Создать .ssh директорию, если не существует
if [ ! -d "${HOME}/.ssh" ]; then
  mkdir "${HOME}/.ssh" || exit 1
  chmod 0600 "${HOME}/.ssh" || exit 1
fi

# Разбор параметров
for p in "$@"; do
  case $p in
  "-yes") __YES__=1 ;;
  "-debug") __DEBUG__=1 ;;
  "-quiet") __QUIET__=1 ;;
  "-force") __FORCE__=1 ;;
  "-dry") __DRY__=1 ;;
  "help" | "-help" | "--help" | "h" | "-h") __HELP__=1 ;;
  "-short") __SHORT__=1 ;;
  *)
    if [ ! -f "$CORE_CONF_REST_ARGS_FILE" ]; then
      CORE_CONF_REST_ARGS_FILE=$(mktemp) || exit 1
    fi

    echo "$p" >>"$CORE_CONF_REST_ARGS_FILE"
    ;;
  esac
done

unset p

[ -n "$__QUIET__" ] && [ -n "$__DEBUG__" ] &&
  __err__ "конфликт флагов -quiet и -debug не могут быть установлены одновременно" &&
  exit 1

#
# логгер
# использует __QUIET__=1 для подавления вывода

CORE_LOGGER_NAME="self"
CORE_LOGGER_USE_DATA=

__CORE_LOGGER_SUB_SYSTEM_NAME__=$(basename "$0") || exit 1

__YELLOW__='\033[1;33m'
__LIGHT__BLUE__='\033[1;34m'
__RED__='\033[0;31m'
__GREEN__='\033[0;32m'
__RED__='\033[0;31m'
__GREEN__='\033[0;32m'
__BLUE__='\033[0;34m'
__PURPLE__='\033[0;35m'
__CYAN__='\033[0;36m'
__LIGHT__GRAY__='\033[0;37m'
__DARK__GRAY__='\033[1;30m'
__LIGHT__RED__='\033[1;31m'
__LIGHT__GREEN__='\033[1;32m'
__NC__='\033[0m'

core_logger_sub_system_name() {
  output=
  [ -n "$CORE_LOGGER_USE_DATA" ] && output="[$(date)]"
  [ -n "$__CORE_LOGGER_SUB_SYSTEM_NAME__" ] && output="${output}[$__CORE_LOGGER_SUB_SYSTEM_NAME__]"
  echo "$output"
}

__err__() {
  [ -z "$__QUIET__" ] &&
    echo "[$CORE_LOGGER_NAME][ERRO]$(core_logger_sub_system_name) $*" >&2
}

__warn__() {
  [ -z "$__QUIET__" ] &&
    echo "[$CORE_LOGGER_NAME][WARN]$(core_logger_sub_system_name) $*"
}

__info__() {
  [ -z "$__QUIET__" ] &&
    echo "[$CORE_LOGGER_NAME][INFO]$(core_logger_sub_system_name) $*"
}

__debug__() {
  [ -z "$__QUIET__" ] &&
    echo "[$CORE_LOGGER_NAME][DEBU]$(core_logger_sub_system_name) $*"
}

#
# методы
#

#
__core_show_variables__() {
  echo "__YES__   = ${__YES__}"
  echo "__DEBUG__ = ${__DEBUG__}"
  echo "__QUIET__ = ${__QUIET__}"
  echo "__FORCE__ = ${__FORCE__}"
  echo "__HELP__  = ${__HELP__}"
  echo "__SHORT__ = ${__SHORT__}"
  echo "__DRY__   = ${__DRY__}"
}

# получить файл с не обработанными аргументами командной строки
__core_conf_get_rest_args__() {
  [ -f "$CORE_CONF_REST_ARGS_FILE" ] && echo "$CORE_CONF_REST_ARGS_FILE" && return 0
  return 1
}

# получить название доступного приложения виртуализации (podman/docker)
__core_get_virtualization_app__() {
  CMD="podman"
  which "$CMD" >/dev/null || CMD="docker"
  which "$CMD" >/dev/null
  [ $? -ne 0 ] && __err__ "нет podman/docker" && exit 1
  echo $CMD
}

# проверить, есть ли образ
# $1 - название образа [name:1.0]
# return 1 - нет образа
# return 2 - ошибка
__core_has_docker_image__() {
  name=$1
  cmd=$(__core_get_virtualization_app__) || return 2

  HAS=$($CMD image ls --filter=reference="$IMAGE" -q) || return 2
  [ -n "$HAS" ] && return 0
  return 1
}

#
# Общие
#

# Запрос подтверждения
# Если __YES__= 1, то yes
# return 0 - yes
# return 1 - no
__confirm__() {
  [ -n "$__YES__" ] && return 0
  msg="Подтвердить ?"
  [ -n "$1" ] && msg="$1"

  while true; do
    read -rp "$msg  [y/N]: " ans

    case $ans in
    "y" | "Y") return 0 ;;
    "" | "n" | "N") return 1 ;;
    esac
  done
}

# Абсолютный путь к файлу
# $1 - путь к файлу/директории
__absolute_path__() {
  [ -z "$1" ] && __err__ "не передан путь к файлу / директории" && return 1
  echo "$1" | grep -E "^/" -q && echo "$1" || echo "${PWD}/$1"
}
