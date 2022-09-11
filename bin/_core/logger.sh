#!/bin/sh

# логгер
# использует __QUIET__=1 для подавления вывода

CORE_LOGGER_NAME="self"
CORE_LOGGER_USE_DATA=

__CORE_LOGGER_SUB_SYSTEM_NAME__=$(basename "$0")

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
