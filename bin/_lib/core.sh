#!/bin/bash

#
# Конфигурация
# -force
# -debug
# -yes
#
# __ENVI_BIN__ = путь к bin, устанавливаетс в профайле

# Директория хранения данных. Есть копии в других файлах
__CORE_STATE_DIR__="${HOME}/_envi_state"

# Файл профиля пользователя в операционной системе
CORE_PROFILE_FILE="${HOME}/.profile_envi"

# Инфраструктура ключей vpn
__CORE_VPN_PKI_DIR__="${HOME}/.vpn_pki"

# Время последнего обновления репозитория
__CORE_TIME_REPO_LAST_UPDATED__="${__CORE_STATE_DIR__}/last-update-repo"

# Отвечать утвердительно на запросы к пользователю
__YES__=

# дебаг режим. конфликтует с QUIET
__DEBUG__=
__DEBUG_ARG__=

# тихий режим, не выводить сообщения. конфликтует с DEBUG
__QUIET__=

# выполнять действия без запроса подтверждения (например перезапись файлов)
__FORCE__=

# не производить изменений
__DRY__=
__DRY_ARG__=

# вывод подсказки
__HELP__=

__SHORT__=

# Файл содержит не обработанные аргументы командной строки
CORE_REST_ARGS_FILE=

# Использовать цвета в терминале для логов
CORE_LOGGER_COLOR_TERMINAL=1

# Разбор параметров
for p in "$@"; do
  case $p in
  "-yes") __YES__=1 ;;
  "-debug")
    __DEBUG__=1
    __DEBUG_ARG__="-debug"
    ;;
  "-quiet") __QUIET__=1 ;;
  "-force") __FORCE__=1 ;;
  "-dry")
    __DRY__=1
    __DRY_ARG__="-dry"
    ;;
  "help" | "-help" | "--help" | "h" | "-h") __HELP__=1 ;;
  "-short") __SHORT__=1 ;;
  *)
    if [ ! -f "$CORE_REST_ARGS_FILE" ]; then
      CORE_REST_ARGS_FILE=$(mktemp) || exit 1
    fi

    echo "$p" >>"$CORE_REST_ARGS_FILE"
    ;;
  esac
done

unset p

[ -n "$__QUIET__" ] && [ -n "$__DEBUG__" ] &&
  __err__ "flag conflict -quiet and -debug cannot be set at the same time" &&
  exit 1

#
# логгер
# использует __QUIET__=1 для подавления вывода

CORE_LOGGER_NAME="envi"
CORE_LOGGER_USE_DATA=

__CORE_LOGGER_SUB_SYSTEM_NAME__=$(basename "$0") || exit 1

__YELLOW__='\033[1;33m'
__GREEN__='\033[0;32m'
__RED__='\033[0;31m'
__BLUE__='\033[0;34m'
__PURPLE__='\033[0;35m'
__CYAN__='\033[0;36m'
__LIGHT__BLUE__='\033[1;34m'
__LIGHT__GRAY__='\033[0;37m'
__LIGHT__RED__='\033[1;31m'
__LIGHT__GREEN__='\033[1;32m'
__DARK__GRAY__='\033[1;30m'
__NC__='\033[0m'
__BACKGROUND_BLACK__='\033[40m'
__BACKGROUND_RED__='\033[41m'
__BACKGROUND_GREEN__='\033[42m'
__BACKGROUND_YELLOW__='\033[43m'
__BACKGROUND_DARK_BLUE__='\033[44m'
__BACKGROUND_BLUE__='\033[46m'
__BACKGROUND_PURPLE__='\033[45m'
__BACKGROUND_GRAY__='\033[47m'

# Название подсистемы
core_logger_sub_system_name() {
  CORE_CONF_OUTPUT=
  [ -n "$CORE_LOGGER_USE_DATA" ] && CORE_CONF_OUTPUT="[$(date)]"
  [ -n "$__CORE_LOGGER_SUB_SYSTEM_NAME__" ] &&
    CORE_CONF_OUTPUT="${CORE_CONF_OUTPUT}[$__CORE_LOGGER_SUB_SYSTEM_NAME__]"
  echo "$CORE_CONF_OUTPUT"
}

# Вывод логов
core_conf_logger() {
  coreConfLoggerType=$1
  coreConfColor=$2
  shift
  shift

  coreConfMsg="[$CORE_LOGGER_NAME][$coreConfLoggerType]$(core_logger_sub_system_name) $*"

  if [ -n "$CORE_LOGGER_COLOR_TERMINAL" ]; then
    echo "${coreConfColor}${coreConfMsg}${__NC__}"
  else
    echo "$coreConfMsg"
  fi
}

__err__() {
  [ -n "$__QUIET__" ] && return 0
  core_conf_logger "ERRO" "$__RED__" "$*" >&2
}

__warn__() {
  [ -n "$__QUIET__" ] && return 0
  core_conf_logger "WARN" "$__YELLOW__" "$*"
}

__info__() {
  [ -n "$__QUIET__" ] && return 0
  core_conf_logger "INFO" "$__LIGHT__BLUE__" "$*"
}

__debug__() {
  [ -n "$__QUIET__" ] && return 0
  [ -z "$__DEBUG__" ] && return 0
  core_conf_logger "DEBU" "$__DARK__GRAY__" "$*"
}

#
# методы
#

#
__core_conf_show_variables__() {
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
  [ -f "$CORE_REST_ARGS_FILE" ] && echo "$CORE_REST_ARGS_FILE" && return 0
  return 1
}

# получить название доступного приложения виртуализации (podman/docker)
__core_get_virtualization_app__() {
  CORE_CONF_CMD="podman"
  which "$CORE_CONF_CMD" >/dev/null || CORE_CONF_CMD="docker"
  which "$CORE_CONF_CMD" >/dev/null
  [ $? -ne 0 ] && __err__ "podman/docker not installed" && return 1
  echo $CORE_CONF_CMD
}

# проверить, есть ли образ
# $1 - название образа [name:1.0]
# return 1 - нет образа TODO - изменить на 99
# return 2 - ошибка
__core_has_docker_image__() {
  CORE_CONF_NAME=$1
  CORE_CONF_CMD=$(__core_get_virtualization_app__) || return 2

  CORE_CONF_HAS=$($CORE_CONF_CMD image ls --filter=reference="$CORE_CONF_NAME" -q) || return 2
  [ -n "$CORE_CONF_HAS" ] && return 0
  return 1
}

# Вернет директорию vpn_pki
# return 1 - нет директории или пуста
# TODO заменить использование переменной на этот метод
__core_vpn_pki_dir__() {
  [ ! -d "$__CORE_VPN_PKI_DIR__" ] &&
    __err__ "dir vpn pki is not exist [${__CORE_VPN_PKI_DIR__}]" &&
    return 1

  [ "$(find "$__CORE_VPN_PKI_DIR__" -maxdepth 1 | wc -l)" -le 1 ] &&
    __err__ "dir vpn pki is empty [${__CORE_VPN_PKI_DIR__}]" &&
    return 1

  echo "$__CORE_VPN_PKI_DIR__"
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
  CORE_CONF_MSG="Подтвердить ?"
  [ -n "$1" ] && CORE_CONF_MSG="$1"

  while true; do
    read -rp "$CORE_CONF_MSG  [y/N]: " CORE_CONF_ANS

    case $CORE_CONF_ANS in
    "y" | "Y") return 0 ;;
    "" | "n" | "N") return 1 ;;
    esac
  done
}

__any_key__() {
  CORE_CONF_LAB=
  CORE_CONF_MSG="${__PURPLE__}Press any key to continue${__NC__}"
  [ "$1" ] && CORE_CONF_MSG="$1"
  read -rn 1 -p "$CORE_CONF_MSG: " CORE_CONF_LAB
  echo
  return 0
}

# Абсолютный путь к файлу
# $1 - путь к файлу/директории
__absolute_path__() {
  [ -z "$1" ] && __err__ "Path to file/directory not passed" && return 1
  echo "$1" | grep -E "^/" -q && echo "$1" || echo "${PWD}/$1"
}

# Нормализация пути
# Схлопнуть относительные переходы типа:
# /Users/sem/_environment/bin/../conf.yml => /Users/sem/_environment/conf.yml
__realpath__() {
  echo "$(
    cd "$(dirname "$1")" || return 1
    pwd
  )/$(basename "$1")"
}

# Возвращает путь к директории библиотек
__get_lib_dir__() {
  CORE_TMP_LIB_DIR="$(__realpath__ "${__ENVI_BIN__}/_lib")"
  [ -d "$CORE_TMP_LIB_DIR" ] && echo "$CORE_TMP_LIB_DIR" && return 0
  return 1
}

# Возвращает путь к файлу библиотеки
__get_lib_file__() {
  CORE_TMP_LIB_FILE="$(__realpath__ "${__ENVI_BIN__}/_lib/$1")"
  [ -f "$CORE_TMP_LIB_FILE" ] && echo "$CORE_TMP_LIB_FILE" && return 0
  __err__ "Нет файла [$CORE_TMP_LIB_FILE]"
  return 1
}

# Возвращает путь к файлу конфигурации
__get_config_file__() {
  CORE_TMP_CONFIG_FILE="$(__realpath__ "${__ENVI_BIN__}/../conf.yml")"
  [ -f "$CORE_TMP_CONFIG_FILE" ] && echo "$CORE_TMP_CONFIG_FILE" && return 0
  return 1
}

# Получить конфигурацию
# $1 - optional обработчик
# $2 - required префикс запрошенного значения
# $3 - optional поле для выбора значения
__config__() {
  CORE_HANDLER="$1"
  CORE_PREFIX="$2"
  CORE_COLUMN="$3"

  if [ -n "$CORE_COLUMN" ]; then
    echo "$CORE_COLUMN" | grep -iEq "^_|_$" &&
      __err__ "Имя поля не должен начинаться и заканчиватся с [_]" && return 1
  fi

  core_parse_yaml_pipe() {
    data_type=
    map_used_keys=

    if [ -z "$CORE_HANDLER" ]; then
      default_handler() { echo "$*"; }
      CORE_HANDLER="default_handler"
    fi

    define_data_type() {
      [ -z "$1" ] && return 0
      [ -z "$data_type" ] && data_type=$1 && return 0
      [ "$data_type" != "$1" ] &&
        __err__ "Смешанный тип значений prefix=[$CORE_PREFIX] val1=[${data_type}], val2[$1]" &&
        return 1
      return 0
    }

    # Вывод одиночного значения (single | array)
    handler_single_pipe() { while read -r line; do $CORE_HANDLER "$line"; done; }

    # Вывод map (key - value)
    handler_pair() { $CORE_HANDLER "$1" "$2"; }

    # Возвратить значение из строки
    rest_val_pipe() { while read -r line; do rest_val "$line"; done; }

    # Возвратить значение из строки (правая часть строки) ......=......
    # shellcheck disable=SC2046
    rest_val() { echo "$1" | cut -b $(echo "$1" | grep -iEo "^[^=]*=" | wc -m)-; }

    while read -r line; do
      t=
      echo "$line" | grep -iEq "^=" && t="single"    # start with `=` :одно значение
      echo "$line" | grep -iEq "^_\d+=" && t="array" # start with `_\d+=` :массив значений
      echo "$line" | grep -iEq "^_[^_]+_" && t="map" # start with `_[^_]+_` :map

      case "$t" in
      "single")
        define_data_type "single" || return 1
        echo "$line" | cut -b 2- | handler_single_pipe
        ;;

      "array")
        define_data_type "array" || return 1
        echo "$line" | grep -iEo "[^=]+$" | handler_single_pipe
        ;;

      "map")
        key=$(echo "$line" | grep -iEo "^_[^_]+" | cut -b 2-)
        echo "$map_used_keys" | grep -iEq "\s${key}\s" && continue # префикс + ключ уже обработан

        if [ -n "$CORE_COLUMN" ]; then
          echo "$line" | grep -iEq "_${key}_${CORE_COLUMN}" || continue # префикс + поле не найдено

          if echo "$line" | grep -iEq "_${key}_${CORE_COLUMN}="; then
            define_data_type "map" || return 1
            handler_pair "$key" "$(rest_val "$line")"
            continue
          fi
        fi

        define_data_type "single" || return 1
        echo "$key" | handler_single_pipe

        map_used_keys="${map_used_keys} ${key} "
        ;;

      *)
        __err__ "unknown type: $line"
        return 1
        ;;
      esac
    done
  }

  CORE_LIB_FILE="$(__get_lib_file__ "parse_yaml.sh")" || return 1
  CORE_CONFIG_FILE="$(__get_config_file__)" || return 1

  set -o pipefail
  sh "$CORE_LIB_FILE" "$CORE_CONFIG_FILE" "$CORE_PREFIX" | core_parse_yaml_pipe

  unset core_parse_yaml_pipe CORE_HANDLER CORE_PREFIX CORE_COLUMN CORE_LIB_DIR
}

#
#
# Проверка и подготовка
#
#

# Создать директорию данных окружения, если не существует
if [ ! -d "$__CORE_STATE_DIR__" ]; then
  __debug__ "Нет директории [$__CORE_STATE_DIR__]. Создать..."

  mkdir "$__CORE_STATE_DIR__" || exit 1
fi

# Создать .ssh директорию, если не существует
if [ ! -d "${HOME}/.ssh" ]; then
  __debug__ "Нет директории [${HOME}/.ssh]. Создать + установить chmod 0700..."

  mkdir "${HOME}/.ssh" || exit 1
  chmod 0700 "${HOME}/.ssh" || exit 1
fi
