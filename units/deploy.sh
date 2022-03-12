#!/bin/bash

#************************************************************
# DEPLOYMENT
# ENV_DAEMON_PID_FILE - пусть к файлу pid процесса сервиса
#
# TODO если запущен /usr/bin/ssh но не запущен /usr/lib/autossh/autossh
# нужно завершить процесс ssh и снова запустить autossh
#
#sudo vim /etc/systemd/system/crone-shell.service
#sudo systemctl daemon-reload
#sudo systemctl start "crone-shell.service"
#sudo systemctl stop "crone-shell.service"
#sudo systemctl enable "crone-shell.service"
#sudo systemctl status crone-shell
#************************************************************

_BIN_=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")
_URL_SSH_CONFIG_="https://raw.githubusercontent.com/semenovem/environment/master/units/ssh-config.txt"
_SERVICE_NAME_="crone-shell"
_MODE_=
_DEBUG_=
_MAIN_CMD_=
_CLI_=true
_SHELL_=$(which bash) || (echo "ERR: which bash" && exit 1)
_VERSION_="1.0"

_DAEMON_TIMEOUT_SLEEP_=86400 # 3600s * 24h
_SERVICE_FILE_=
_SYSTEMMD_DIR_="/etc/systemd/system"

_SSH_PROXY_TUNNEL_RU_="ru-tunnel"
_SSH_PROXY_TUNNEL_EU_="eu-tunnel"

# TODO - получить из файла конфигурации
_DAEMON_PID_FILE_="$ENV_DAEMON_PID_FILE"
_DAEMON_WORKING_DIR_="${HOME}/_service_daemon"
_DAEMON_USER_="evg"
_DAEMON_PORT_="2022"
_DAEMON_HOST_="localhost"
_DAEMON_LOGFILE_NAME_="logfile.txt"

_TASK_USER_=              # Создание пользователей
_TASK_SSH_ACCESS=         # Настройка ssh доступов
_TASK_SSH_KEYS=           # Настройка ssh ключей
_TASK_SSH_CHECK_CONN_=    # Проверка подключения
_TASK_SERVICE_INSTALL_=   # Установка сервиса
_TASK_SERVICE_UNINSTALL_= # Удаление сервиса
_TASK_SERVICE_START_=     # Сервис
_TASK_SERVICE_STOP_=      # Сервис
_TASK_SERVICE_STATUS_=    # Сервис

_ARG_CONFIRM_YES_=
_ARG_DEBUG_=
_ARG_START_=
_ARG_STOP_=
_ARG_STATUS_=
_ARG_INSTALL_=
_ARG_CHECK_SSH_=
_ARG_UNINSTALL_=

#************************************************************
# CONSTANTS                                                 *
#************************************************************
function const() {
  _CONST_MODE_INIT_STATION_="station"
  _CONST_MODE_INIT_SERVER_="server"
  _CONST_MODE_INIT_PROXY_="proxy"

  # deprecated
  _CONST_MODE_SERVICE_="service"
  _CONST_MODE_DAEMON_START_="daemon-start"
  _CONST_MODE_DAEMON_="daemon"

  _CONST_CMD_UPD_SSH_CFG_="update-ssh-config"
  _CONST_CMD_SERVICE_="service"
  _CONST_CMD_DAEMON_START_="daemon-start"
  _CONST_CMD_DAEMON_="daemon"


  _CONST_MODES="$_CONST_MODE_INIT_STATION_"
  _CONST_MODES="${_CONST_MODES} ${_CONST_MODE_INIT_SERVER_}"
  _CONST_MODES="${_CONST_MODES} ${_CONST_MODE_INIT_PROXY_}"
  _CONST_MODES="${_CONST_MODES} ${_CONST_MODE_SERVICE_}"
  _CONST_MODES="${_CONST_MODES} ${_CONST_MODE_DAEMON_START_}"
  _CONST_MODES="${_CONST_MODES} ${_CONST_MODE_DAEMON_}"
}
const

#************************************************************
# COMMON                                                    *
#************************************************************
function showConfig() {
  drawCfgItel "_VERSION_                = ${_VERSION_}"
  drawCfgItel "_CMD_                    = ${_MAIN_CMD_}"
  drawCfgItel "_DEBUG_                  = ${_DEBUG_}"
  drawCfgItel "_CONFIRM_YES_            = ${_CONFIRM_YES_}"
  drawCfgItel "_CLI_                    = ${_CLI_}"
  drawCfgItel "_SSH_CONFIG_             = ${_SSH_CONFIG_}"

  drawCfgItel "_SERVICE_NAME_           = ${_SERVICE_NAME_}"
  drawCfgItel "_SERVICE_FILE_           = ${_SERVICE_FILE_}"
  drawCfgItel "_DAEMON_PID_FILE_        = ${_DAEMON_PID_FILE_}"
  drawCfgItel "_DAEMON_WORKING_DIR_     = ${_DAEMON_WORKING_DIR_}"
  drawCfgItel "_DAEMON_USER_            = ${_DAEMON_USER_}"
  drawCfgItel "_DAEMON_PORT_            = ${_DAEMON_PORT_}"
  drawCfgItel "_DAEMON_HOST_            = ${_DAEMON_HOST_}"
  drawCfgItel "_SSH_PROXY_TUNNEL_RU_    = ${_SSH_PROXY_TUNNEL_RU_}"
  drawCfgItel "_SSH_PROXY_TUNNEL_EU_    = ${_SSH_PROXY_TUNNEL_EU_}"
  drawCfgItel "_DAEMON_LOGFILE_NAME_    = ${_DAEMON_LOGFILE_NAME_}"
  drawCfgItel "_DAEMON_LOGFILE_FILE_    = ${_DAEMON_LOGFILE_FILE_}"
  drawCfgItel "_DAEMON_TIMEOUT_SLEEP_   = ${_DAEMON_TIMEOUT_SLEEP_}"
  drawCfgItel "ENV_DAEMON_PID_FILE      = ${ENV_DAEMON_PID_FILE}"

  drawCfgItel "_MODE_                   = ${_MODE_}"
  drawCfgItel "_ARG_START_              = ${_ARG_START_}"
  drawCfgItel "_ARG_STOP_               = ${_ARG_STOP_}"
  drawCfgItel "_ARG_STATUS_             = ${_ARG_STATUS_}"
  drawCfgItel "_ARG_INSTALL_            = ${_ARG_INSTALL_}"
  drawCfgItel "_ARG_UNINSTALL_          = ${_ARG_UNINSTALL_}"
  drawCfgItel "_ARG_CHECK_SSH_          = ${_ARG_CHECK_SSH_}"

  drawCfgItel "_TASK_USER_              = ${_TASK_USER_}"
  drawCfgItel "_TASK_SSH_ACCESS         = ${_TASK_SSH_ACCESS}"
  drawCfgItel "_TASK_SSH_KEYS           = ${_TASK_SSH_KEYS}"
  drawCfgItel "_TASK_SSH_CHECK_CONN_    = ${_TASK_SSH_CHECK_CONN_}"
  drawCfgItel "_TASK_SERVICE_INSTALL_   = ${_TASK_SERVICE_INSTALL_}"
  drawCfgItel "_TASK_SERVICE_START_     = ${_TASK_SERVICE_START_}"
  drawCfgItel "_TASK_SERVICE_STOP_      = ${_TASK_SERVICE_STOP_}"
  drawCfgItel "_TASK_SERVICE_STATUS_    = ${_TASK_SERVICE_STATUS_}"
}

function help() {
  echo "Usage:"
  echo "    ${_CONST_CMD_UPD_SSH_CFG_}   обновить конфигурацию .ssh/config"
  echo "    ${_CONST_CMD_SERVICE_}             операции с сервисом"
  echo "    ${_CONST_CMD_DAEMON_START_}        запуск демона"
  echo "    ${_CONST_CMD_DAEMON_}              демон"

  echo "Common params:"
  echo "    -v | -debug"
  echo "    -cli           подсветка текста"

#  echo "Examples:"
#  echo "  -v -mode station"
#  echo "  -v -mode server"
#  echo "  -v -mode service -install -start -status"
#  echo "  -v -mode daemon-start"
#  echo "  -m | -mode     режим [${_CONST_MODES}]"
#  echo "  -modeƒ [${_CONST_MODES}] [-options]"
#
#
#  echo "  -mode service [-install -start -stop -status -uninstall]"
#  echo "        Работа с демоном"
#  echo "  -mode [station server proxy]   настройка машин"
#  echo "        -check-ssh   проверить подключение ssh"
#  echo "  -mode daemon-start"
#  echo "        для запуска демона (shell script)"
}

# checks if the user is created
function existUser() {
  local u=$1
  grep "${u}:" /etc/passwd -q && info "Пользователь '${u}' существует" && return 0
  info "Пользователь '${u}' не существует"
  return 1
}

# Loading ssh configuration
function loadSshConfig() {
  local tmp=$1
  info "Получение/создание конфигурации ssh '_SSH_CONFIG_'"
  curl -o "$tmp" -LO "$_URL_SSH_CONFIG_"
  grep "404: Not Found" -q "$tmp" &&
    echo "Файл '${_URL_SSH_CONFIG_}' не удалось загрузить" &&
    return 1
  return 0
}

function checkSshConnect() {
  local conn=$1
  ssh -o stricthostkeychecking=no \
    -o userknownhostsfile=/dev/null \
    -o passwordauthentication=no \
    "$conn" : 2>/dev/null \
    && outOk "Есть подключение к '${conn}'" \
    && return 0

  warn "Нет подключения к '${conn}'"
  return 1
}

function debug() {
  [ -z "$_DEBUG_" ] && return 0
  [ "$_CLI_" ] && echo -e "${_DARK_GRAY_}$*${_NC_}" || echo -e "$*"
}
function info() {
  local s="[INFO] $*"
  [ "$_CLI_" ] && echo -e "${_GREEN_}${s}${_NC_}" || echo -e "$s"
}
function warn() {
  local s="[INFO] $*"
  [ "$_CLI_" ] && echo -e "${_YELLOW_}${s}${_NC_}" || echo -e "$s"
}
function err() {
  local s="[ERROR] $*"
  [ "$_CLI_" ] && echo -e "${_RED_}${s}${_NC_}" || echo -e "$s"
}
function outOk() {
  [ "$_CLI_" ] && echo -e "${_LIGHT_GREEN_}$*${_NC_}" || echo -e "$*"
}
function drawCfgItel() {
  [ "$_CLI_" ] && echo -e "${_CYAN_}$*${_NC_}" || echo -e "$*"
}

function colors() {
  export _RED_='\033[0;31m'
  export _GREEN_='\033[0;32m'
  export _YELLOW_='\033[1;33m'
  export _BLUE_='\033[0;34m'
  export _LIGHT_BLUE_='\033[1;34m'
  export _PURPLE_='\033[0;35m'
  export _CYAN_='\033[0;36m'
  export _LIGHT_GRAY_='\033[0;37m'
  export _DARK_GRAY_='\033[1;30m'
  export _LIGHT_RED_='\033[1;31m'
  export _LIGHT_GREEN_='\033[1;32m'
  export _NC_='\033[0m' # No Color
  export _BACKGROUND_BLACK_='\033[40m'
  export _BACKGROUND_RED_='\033[41m'
  export _BACKGROUND_GREEN_='\033[42m'
  export _BACKGROUND_YELLOW_='\033[43m'
  export _BACKGROUND_DARK_BLUE_='\033[44m'
  export _BACKGROUND_BLUE_='\033[46m'
  export _BACKGROUND_PURPLE_='\033[45m'
  export _BACKGROUND_GRAY_='\033[47m'
}
colors
unset colors

#************************************************************
# PARAMETER PARSING                                         *
#************************************************************
function parseArgs() {
  local prev p has

  case $1 in
    "$_CONST_CMD_UPD_SSH_CFG_")
      has=1
      _MAIN_CMD_="$_CONST_CMD_UPD_SSH_CFG_"
      ;;
    "$_CONST_CMD_SERVICE_") _MAIN_CMD_="$_CONST_CMD_SERVICE_"; has=1 ;;
    "$_CONST_CMD_DAEMON_START_") _MAIN_CMD_="$_CONST_CMD_DAEMON_START_"; has=1 ;;
    "$_CONST_CMD_DAEMON_") _MAIN_CMD_="$_CONST_CMD_DAEMON_"; has=1 ;;
    *) echo "_____________" ;;
  esac

  [ "$has" ] && shift

  [ -z "$_MAIN_CMD_" ] \
    && err "parameter parsing. operation not submittedd"\
    && help \
    && return 1

  # common parametrs
  for p in "$@"; do
    case $p in
    "-debug" | "-v") _DEBUG_=true ;;
    "-y" | "-yes") _CONFIRM_YES_=true ;;
    "-cli") _CLI_=true ;;
    *) prev=$p ;;
    esac
  done

  for p in "$@"; do
    if [ "$prev" ]; then
      case $prev in
      "-mode" | "-m") _MODE_="$p" ;;
      *) warn "Unknown arguments: $prev $p" && exit 1 ;;
      esac
      prev=
      continue
    fi

    case $p in
    "-debug" | "-v") _ARG_DEBUG_=true ;;
    "-y" | "-yes") _ARG_CONFIRM_YES_=true ;;
    "-start") _ARG_START_=true ;;
    "-stop") _ARG_STOP_=true ;;
    "-install") _ARG_INSTALL_=true ;;
    "-uninstall") _ARG_UNINSTALL_=true ;;
    "-status") _ARG_STATUS_=true ;;
    "-check-ssh") _ARG_CHECK_SSH_=true ;;
    "-cli") _CLI_=true ;;
    *) prev=$p ;;
    esac
  done
}

parseArgs "$@" || exit 1
unset parseArgs

#************************************************************
# CHECK                                                     *
#************************************************************
#function configCheck() {
#  local ERR it mod
#
#  [ -z "$_MODE_" ] && ERR=true && help
#
#  if [ "$_MODE_" ]; then
#    for it in $ $_CONST_MODES; do
#      [ "$_MODE_" == "$it" ] && mod=true
#    done
#    [ -z "$mod" ] && ERR=true \
#      && err "incorrect mode specified -mode='$_MODE_' must -mode=[${_CONST_MODES}]"
#  fi
#
#  [ -z "$_SHELL_" ] && err "Не найден bash" && ERR=1
#
#  [ "$ERR" ] && showConfig && err "Launch aborted" && return 1
#  return 0
#}

#configCheck || exit 1
#unset configCheck

#************************************************************
# SETUP                                                     *
#************************************************************
function setup() {
  _SSH_CONFIG_="${HOME:?}/.ssh/config"
  [ "$_SERVICE_NAME_" ] && _SERVICE_FILE_="${_SYSTEMMD_DIR_:?}/${_SERVICE_NAME_:?}.service"
  [ -z "$_DAEMON_PID_FILE_" ] && _DAEMON_PID_FILE_="${_DAEMON_WORKING_DIR_:?}/${_SERVICE_NAME_}.pid"
  [ -z "$_DAEMON_LOGFILE_FILE_" ] && _DAEMON_LOGFILE_FILE_="${_DAEMON_WORKING_DIR_:?}/${_DAEMON_LOGFILE_NAME_}"

  case $_MODE_ in
  "$_CONST_MODE_INIT_SERVER_" | "$_CONST_MODE_INIT_PROXY_")
    _TASK_USER_=true
    [ "$_ARG_CHECK_SSH_" ] && _TASK_SSH_CHECK_CONN_=true
    ;;

  "$_CONST_MODE_INIT_SERVER_") _TASK_SERVICE_INSTALL_=true ;;

    # Сервис systemctl
  "$_CONST_MODE_SERVICE_")
    [ "$_ARG_START_" ] && _TASK_SERVICE_START_=true
    [ "$_ARG_STOP_" ] && _TASK_SERVICE_STOP_=true
    [ "$_ARG_STATUS_" ] && _TASK_SERVICE_STATUS_=true
    [ "$_ARG_INSTALL_" ] && _TASK_SERVICE_INSTALL_=true
    [ "$_ARG_UNINSTALL_" ] && _TASK_SERVICE_UNINSTALL_=true
    ;;
  esac

  [ "$_ARG_DEBUG_" ] && _DEBUG_=true
}
setup
unset setup
[ "$_DEBUG_" ] && showConfig

#************************************************************
# APP                                                       *
#************************************************************
# TODO установка ПО

# назначение имени машины
#sudo echo "srv1" > /etc/hostname

#************************************************************
# USERS                                                     *
#************************************************************
function taskUserServer() {
  local user
  debug "server: users"

  user="adm"
  existUser "$user"
  if [ $? -eq 1 ]; then
    info "Создать пользователя '${user}'"

    # добавить sudo
    # добавить публичные ключи для доступа по ssh
    echo "no"
  fi

  user="remote"
  existUser "$user"
  if [ $? -eq 1 ]; then
    info "Создать пользователя '${user}'"

    # добавить sudo
    # добавить публичные ключи для доступа по ssh
    echo "no"
  fi
}
[ "$_TASK_USER_" ]  && [ "$_MODE_" == "$_CONST_MODE_INIT_SERVER_" ] && taskUserServer
unset taskUserServer


function taskUserProxy() {
  local user
  debug "proxy: users"

  user="proxy-adm"
  info "ПРОВЕРКА ПОЛЬЗОВАТЕЛЯ '${user}'"
  existUser "$user"
  if [ $? -eq 1 ]; then
    info "Создать пользователя '${user}'"

    sudo useradd -m  -G root -s "$_SHELL_" -c "admin on proxy server" "$user"

    # добавить sudo
    # добавить публичные ключи для доступа по ssh
    echo "no"
  fi

  user="proxy"

  info "ПРОВЕРКА ПОЛЬЗОВАТЕЛЯ '${user}'"
  existUser "$user"
  if [ $? -eq 1 ]; then
    info "Создать пользователя '${user}'"

    # добавить sudo
    # добавить публичные ключи для доступа по ssh
    echo "no"
  fi
}
[ "$_TASK_USER_" ] && [ "$_MODE_" == "$_CONST_MODE_INIT_PROXY_" ] && taskUserProxy
unset taskUserProxy

#************************************************************
# SSH KEYS                                                  *
#************************************************************
function taskSshKeys() {
  local t
  # TODO Генерация ключей, если нет + копирование и установка публичных ключей
}
[ "$_TASK_SSH_KEYS" ] && taskSshKeys
unset taskSshKeys

#************************************************************
# SSH CONFIG                                                *
#************************************************************
function taskSshConfig() {
  [ -z "$_SSH_CONFIG_" ] && err " Не установлена переменная '_SSH_CONFIG_'" && return 1
  tmp=$(mktemp) || return 1
  loadSshConfig "$tmp" || return 1
  # TODO Проверить файлы на идентичность по hash-sum, если различные - перезаписать
  # TODO добавить запрос на перезапись файла, если в интерактивном режиме
  cp -f "$tmp" "$_SSH_CONFIG_"
}
[ "$_MAIN_CMD_" = "$_CONST_CMD_UPD_SSH_CFG_" ] && taskSshConfig
unset taskSshConfig

#************************************************************
# SSH CHECK CONNECT                                         *
#************************************************************
function taskCheckSshConnServer() {
  debug "taskCheckSshConnServer"

  checkSshConnect "$_SSH_PROXY_TUNNEL_RU_"
  checkSshConnect "$_SSH_PROXY_TUNNEL_EU_"
}

[ "$_TASK_SSH_CHECK_CONN_" ] && [ "$_MODE_" == "$_CONST_MODE_INIT_SERVER_" ] && taskCheckSshConnServer




#************************************************************
# SERVICES [ INSTALL | START | STOP | RELOAD | UNINSTALL ]
#************************************************************
createServiceFile() {
  echo -e \
"[Unit]
Description = run sh script
After = network.target network-online.target

[Service]
Type = forking
#Environment=ENV_DAEMON_PID_FILE=${_DAEMON_PID_FILE_}
PIDFile = ${_DAEMON_PID_FILE_}
WorkingDirectory = ${_DAEMON_WORKING_DIR_}
User = ${_DAEMON_USER_}
Group = ${_DAEMON_USER_}
ExecStart = /bin/bash ${_BIN_}/$0 -mode ${_CONST_MODE_DAEMON_START_}
TimeoutSec=60
Restart=always

[Install]
WantedBy = multi-user.target" > "$1"
}

# --- stop
function taskServiceStop() {
  debug "service stop"
  sudo systemctl stop "${_SERVICE_NAME_}.service"
}
[ "$_TASK_SERVICE_STOP_" ] && taskServiceStop

# --- install
function taskServiceInstall() {
  local tmp
  debug "service install"
  [ -z "$_SERVICE_FILE_" ] && warn "Не установлен путь к shell скрипту" && return 1
  [ -z "$_DAEMON_WORKING_DIR_" ] && warn "Не установлено значение _DAEMON_WORKING_DIR_" && return 1
  tmp=$(mktemp) || return 1
  createServiceFile "$tmp" || return 1
  sudo mv "$tmp" "$_SERVICE_FILE_" || return 1
  sudo systemctl daemon-reload
}
[ "$_TASK_SERVICE_INSTALL_" ] && taskServiceInstall

# --- start
function taskServiceStart() {
  debug "service start"
  sudo systemctl start "${_SERVICE_NAME_}.service"
  sudo systemctl enable "${_SERVICE_NAME_}.service"
}
[ "$_TASK_SERVICE_START_" ] && taskServiceStart

# --- status
function taskServiceStatus() {
  debug "service status"
  sudo systemctl status "$_SERVICE_NAME_"
}
[ "$_TASK_SERVICE_STATUS_" ] && taskServiceStatus

# --- uninstall
function taskServiceUninstall() {
  debug "service uninstall"
  sudo systemctl stop "${_SERVICE_NAME_}.service"
  sudo systemctl disable "${_SERVICE_NAME_}.service"
  sudo rm -rf "$_SERVICE_FILE_"

  sudo systemctl daemon-reload
  sudo systemctl reset-failed
}
[ "$_TASK_SERVICE_UNINSTALL_" ] && taskServiceUninstall

#************************************************************
# DAEMON START                                              *
#************************************************************
function taskDaemonStart() {
  local argDebug
  debug "daemon start"
  [ "$_DEBUG_" ] && argDebug="-debug"
  $_SHELL_ "$0" -mode "$_CONST_MODE_DAEMON_" "$argDebug" &
  sleep 3
}
[ "$_CONST_MODE_DAEMON_START_" == "$_MODE_" ] && (taskDaemonStart; exit 0)

#************************************************************
# DAEMON                                                    *
#************************************************************
[ "$_CONST_MODE_DAEMON_" != "$_MODE_" ] && exit 0
function getNameAutosshConn() {
  local p
  for p in "$@"; do
    [[ "$p" == "${_DAEMON_PORT_}:${_DAEMON_HOST_}:22"* ]] && echo "$p ${!#}" && return 0
  done
  err "Не корректные входные данные: '$*'"
  return 1
}

function existAutosshConn() {
  local conn=$1
  # shellcheck disable=SC2009
  pid="$(ps -aux | grep "$conn" | grep -v grep | awk '{print $2}')" || return 1
  [ -z "$pid" ] && return 1
  return 0
}

function connectSsh() {
  conn=$(getNameAutosshConn "$@") || return 1
  existAutosshConn "$conn" && debug "Connection already established [${conn}]" && return 0
  debug "Connection to [${conn}]"
  autossh "$@"
}

function taskDaemon() {
  debug "daemon"

  mkdir -p "$_DAEMON_WORKING_DIR_"
  [ $? -ne 0 ] && warn "Не создана директория ${_DAEMON_WORKING_DIR_}" && return 1

# TODO для отладки
#  _DEBUG_=true
#  _CLI_=

  [ -z "$_DAEMON_PID_FILE_" ] && warn "Не установлено значение _DAEMON_PID_FILE_"
  [ -z "$_DAEMON_PORT_" ] && warn "Не установлено значение _DAEMON_PORT_"
  [ -z "$_DAEMON_HOST_" ] && warn "Не установлено значение _DAEMON_HOST_"
  [ -z "$_SSH_PROXY_TUNNEL_RU_" ] && warn "Не установлено значение _SSH_PROXY_TUNNEL_RU_"
  [ -z "$_SSH_PROXY_TUNNEL_EU_" ] && warn "Не установлено значение _SSH_PROXY_TUNNEL_EU_"
  [ -z "$_DAEMON_LOGFILE_FILE_" ] && warn "Не установлено значение _DAEMON_LOGFILE_FILE_"

  exec >>"$_DAEMON_LOGFILE_FILE_"
  exec 2>>"$_DAEMON_LOGFILE_FILE_"

  while true; do
    [ "$_DAEMON_PID_FILE_" ] && echo $$ >"$_DAEMON_PID_FILE_"

    connectSsh -M 0 \
      -o "ServerAliveInterval 30" \
      -o "ServerAliveCountMax 3" \
      -o "PubkeyAuthentication=yes" \
      -o "StrictHostKeyChecking=false" \
      -o "PasswordAuthentication=no" \
      -fNR "${_DAEMON_PORT_}:${_DAEMON_HOST_}:22" "$_SSH_PROXY_TUNNEL_RU_"

    connectSsh -M 0 \
      -o "ServerAliveInterval 30" \
      -o "ServerAliveCountMax 3" \
      -o "PubkeyAuthentication=yes" \
      -o "StrictHostKeyChecking=false" \
      -o "PasswordAuthentication=no" \
      -fNR "${_DAEMON_PORT_}:${_DAEMON_HOST_}:22" "$_SSH_PROXY_TUNNEL_EU_"

    sleep "$_DAEMON_TIMEOUT_SLEEP_"

  # TODO 1 раз в сутки - обновлять файл ssh/config
  # TODO 1 раз с сутки - обновлять файл deploy на новую версию
  done
}
[ "$_CONST_MODE_DAEMON_" == "$_MODE_" ] && taskDaemon
