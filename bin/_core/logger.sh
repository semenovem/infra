#!/bin/sh

CORE_LOGGER_NAME="self"
CORE_LOGGER_USE_DATA=

__CORE_LOGGER_SUB_SYSTEM_NAME__=$(basename "$0")

core_logger_sub_system_name() {
  output=
  [ -n "$CORE_LOGGER_USE_DATA" ] && output="[$(date)]"
  [ -n "$__CORE_LOGGER_SUB_SYSTEM_NAME__" ] && output="${output}[$__CORE_LOGGER_SUB_SYSTEM_NAME__]"
  echo "$output"
}

core_logger_use_data() {
  [ -n "$CORE_LOGGER_USE_DATA" ] && echo "[$(date)]"
}

__err__() {
  echo "[$CORE_LOGGER_NAME][ERRO]$(core_logger_sub_system_name) $*"
}

__warn__() {
  echo "[$CORE_LOGGER_NAME][WARN]$(core_logger_sub_system_name) $*"
}

__info__() {
  echo "[$CORE_LOGGER_NAME][INFO]$(core_logger_sub_system_name) $*"
}

__debug__() {
  echo "[$CORE_LOGGER_NAME][DEBU]$(core_logger_sub_system_name) $*"
}
