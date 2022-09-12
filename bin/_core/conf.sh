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

# дебаг режим
__DEBUG__=

# выполнять действия без запроса подтверждения (например перезапись файлов)
__FORCE__=

# отвечать утвердительно на запросы к пользователю
__YES__=

# тихий режим, не выводить сообщения
__QUIET__=

__HELP__=

__SHORT__=

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
  "-debug") __DEBUG__=1 ;;
  "-yes") __YES__=1 ;;
  "-quiet") __QUIET__=1 ;;
  "-force") __FORCE__=1 ;;
  "help" | "-help" | "--help" | "h" | "-h") __HELP__=1 ;;
  "-short") __SHORT__=1 ;;
  esac
done
unset p
