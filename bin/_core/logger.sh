#!/bin/sh

# логгер
# использует __QUIET__=1 для подавления вывода

CORE_LOGGER_NAME="self"
CORE_LOGGER_USE_DATA=

__CORE_LOGGER_SUB_SYSTEM_NAME__=$(basename "$0")

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
    echo "[$CORE_LOGGER_NAME][ERRO]$(core_logger_sub_system_name) $*"
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
