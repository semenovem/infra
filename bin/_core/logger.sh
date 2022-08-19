#!/bin/sh

CORE_LOGGER_SYSTEM_NAME="self"
__CORE_LOGGER_SUB_SYSTEM_NAME__=$(basename $0)

core_logger_sub_system_name() {
  [ -n "$__CORE_LOGGER_SUB_SYSTEM_NAME__" ] && echo "[$__CORE_LOGGER_SUB_SYSTEM_NAME__] "
}

__err__() {
  echo "[$CORE_LOGGER_SYSTEM_NAME][ERRO] [$(date)] $(core_logger_sub_system_name)$@"
}

__warn__() {
  echo "[$CORE_LOGGER_SYSTEM_NAME][WARN] [$(date)] $(core_logger_sub_system_name)$@"
}

__info__() {
  echo "[$CORE_LOGGER_SYSTEM_NAME][INFO] [$(date)] $(core_logger_sub_system_name)$@"
}

__debug__() {
  echo "[$CORE_LOGGER_SYSTEM_NAME][DEBU] [$(date)] $(core_logger_sub_system_name)$@"
}
