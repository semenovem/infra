#!/bin/bash

PID=$$
FILE_PID=$1 # файл, куда нужно записать pid процесса


APP=/usr/local/bin/autossh


#AUTOSSH_GATETIME=
#AUTOSSH_PORT=0
#AUTOSSH_LOGFILE=
#AUTOSSH_LOGLEVEL=
#AUTOSSH_PIDFILE=


#    AUTOSSH_GATETIME    - how long must an ssh session be established
#                          before we decide it really was established
#                          (in seconds). Default is 30 seconds; use of -f
#                          flag sets this to 0.
#    AUTOSSH_LOGFILE     - file to log to (default is to use the syslog
#                          facility)
#    AUTOSSH_LOGLEVEL    - level of log verbosity
#    AUTOSSH_MAXLIFETIME - set the maximum time to live (seconds)
#    AUTOSSH_MAXSTART    - max times to restart (default is no limit)
#    AUTOSSH_MESSAGE     - message to append to echo string (max 64 bytes)
#    AUTOSSH_PATH        - path to ssh if not default
#    AUTOSSH_PIDFILE     - write pid to this file
#    AUTOSSH_POLL        - how often to check the connection (seconds)
#    AUTOSSH_FIRST_POLL  - time before first connection check (seconds)
#    AUTOSSH_PORT        - port to use for monitor connection
#    AUTOSSH_DEBUG       - turn logging to maximum verbosity and log to
#                          stderr

# Запустить

#start() {
#  local arg=$1
#
#  #  1. проверить, запущен ли сервис
#  #  2. запустить, если не запущен
#
#  /usr/bin/autossh -M 0 \
#    -o "ServerAliveInterval 30" \
#    -o "ServerAliveCountMax 3" \
#    -o "PubkeyAuthentication=yes" \
#    -o "StrictHostKeyChecking=false" \
#    -o "PasswordAuthentication=no" \
#    -fNR 2022:localhost:22 europe
#}

exist() {
  local has
  # shellcheck disable=SC2009
  has="$(ps | grep "$*" | grep -v grep | awk '{print $1}')"
  [ -z "$has" ] && return 1
  return 0
}


connect() {
  local arg="$APP $*"
  echo "[DEBUG] $$ $arg"

#  проверить, запущено ли
  exist "$arg" && echo "Соединение уже запущено" && return 0

#  если нет - запустить
#  если соединение упало - перезапустить

  while true; do
    $APP "$@"
    echo ">>>>> connect -- перезапуск:: $$"
  done
}


while true; do
  export AUTOSSH_LOGFILE=/Users/evg/_environment/presets/home/eu.logs
  export AUTOSSH_PIDFILE=/Users/evg/_environment/presets/home/eu.pid
  export AUTOSSH_DEBUG=true

  connect -M 0 \
    -o "ServerAliveInterval 30" \
    -o "ServerAliveCountMax 3" \
    -o "PubkeyAuthentication=yes" \
    -o "StrictHostKeyChecking=false" \
    -o "PasswordAuthentication=no" \
    -NR 2022:localhost:22 europe &

  sleep 15
done
