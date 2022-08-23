#!/bin/sh

#
# Конфигурация
#

# Директория хранения данных. Есть копии в других файлах
__CORE_CONF_STATE_DIR__="${HOME}/_envi_state"

# Файл профиля
__CORE_CONF_PROFILE_FILE__="${HOME}/.profile_envi"

# Время последнего обновления репозитория
__CORE_CONF_LAST_UPDATE_REPO__="${__CORE_CONF_STATE_DIR__}/last-update-repo"

if [ ! -d "$__CORE_CONF_STATE_DIR__" ]; then
  mkdir "$__CORE_CONF_STATE_DIR__" || exit 1
fi
