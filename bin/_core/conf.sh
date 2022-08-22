#!/bin/sh

#
# Конфигурация
#

# Директория хранения данных
__CORE_CONF_STATE_DIR__="${HOME}/_envi_state"

# Файл профиля с bin директориями
__CORE_CONF_PROFILE_BIN_DIRS_FILE__="${HOME}/.profile_envi_bin_dirs"

# Время последнего обновления репозитория
__CORE_CONF_LAST_UPDATE_REPO__="${__CORE_CONF_STATE_DIR__}/last-update-repo"

if [ ! -d "$__CORE_CONF_STATE_DIR__" ]; then
  mkdir "$__CORE_CONF_STATE_DIR__" || exit 1
fi
