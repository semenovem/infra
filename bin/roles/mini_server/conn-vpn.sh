#!/bin/sh

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../../_lib/core.sh" || exit 1

DIR_OPENVPN="${HOME}/openvpn-client"
LOG_FILE="/var/log/openvpn/openvpn-client.log"
PID_FILE="/var/log/openvpn/openvpn-client.pid"

ERR=
OPER_START=
OPER_STOP=
OPER_LOG=
OPER_STAT=1
VPN_CFG_FILE=
OPENVPN_ARGS=

if [ ! -d "$DIR_OPENVPN" ]; then
  mkdir "$DIR_OPENVPN" || exit 1
fi

chmod 0700 "$DIR_OPENVPN" || exit 1
chmod 0600 "${DIR_OPENVPN}/vpn-config"* || exit 1

# ------------------------------------
# ------------------------------------
# ------------------------------------
help() {
  __info__ "use: "
  __info__ "EXAMPLE: ./conn-vpn.sh msk1"
  __info__ "EXAMPLE: ./conn-vpn.sh home"
  __info__ "EXAMPLE: ./conn-vpn.sh stop"
  __info__ "EXAMPLE: ./conn-vpn.sh log"
  __info__ "EXAMPLE: ./conn-vpn.sh"
}

# просмотреть директорию с файлами *.ovpn
check_config() {
  [ -z "$VPN_CFG_FILE" ] && __err__ "No config file" && return 1
  return 0
}

buildCmd() {
  OPENVPN_ARGS="${OPENVPN_ARGS} $*"
}

stopByPID() {
  sudo kill -2 "$1" || sudo rm -rf "$PID_FILE"
}

# =========================================================
# shellcheck disable=SC2068
for p in $@; do
  case "$p" in
  "start" | "connect" | "up") OPER_START=1 ;;
  "stop" | "disconnect" | "down") OPER_STOP=1 ;;
  "log") OPER_LOG=1 ;;
  "-h" | "h" | *"help")
    help
    exit 0
    ;;
  *)
    COUNT=$(find "$DIR_OPENVPN" -iname "*${p}*.ovpn" | wc -l)
    case "$COUNT" in
    0)
      __err__ "unknown argument [${p}]"
      ERR=1
      ;;
    1)
      VPN_CFG_FILE=$(find "$DIR_OPENVPN" -iname "*${p}*.ovpn")
      OPER_START=1
      ;;
    *)
      __err__ "Multiple vpn configuration files found by [${p}]"
      ERR=1
      ;;
    esac
    ;;
  esac
done

[ -n "$VPN_CFG_FILE" ] && __debug__ "The configuration file: [$VPN_CFG_FILE]"
[ -n "$ERR" ] && exit 1

# STOP
if [ -n "$OPER_STOP" ]; then
  OPER_STAT=
  if [ -f "$PID_FILE" ]; then
    __info__ "Stop OPENVPN"
    stopByPID "$(cat "$PID_FILE")"
  else
    __info__ "OPENVPN is already stopped"
  fi
fi

# START
if [ -n "$OPER_START" ]; then
  check_config || exit 1
  __info__ "Start vpn with config file [${VPN_CFG_FILE}]"
  OPER_STAT=

  ps -aux | grep openvpn | grep -v grep | grep -q "$VPN_CFG_FILE"
  if [ $? -eq -0 ]; then
    __info__ "OPENVPN is already running"
  else
    if [ -f "$PID_FILE" ]; then
      stopByPID $(cat "$PID_FILE") || exit 1
    fi

    buildCmd --config "$VPN_CFG_FILE" \
      --log "$LOG_FILE" \
      --writepid "$PID_FILE" \
      --auth-nocache \
      --connect-retry 10 60 \
      --daemon

    # shellcheck disable=SC2086
    sudo openvpn $OPENVPN_ARGS

    OPER_LOG=1
  fi
fi

# ЛОГИ
if [ -n "$OPER_LOG" ]; then
  OPER_STAT=
  [ -f "$LOG_FILE" ] && sudo tail -f "$LOG_FILE"
fi

if [ -n "$OPER_STAT" ]; then
  if [ -f "$PID_FILE" ]; then
    __info__ "Status with PID [$(cat "$PID_FILE")]:"
    sudo ps "$(cat "$PID_FILE")"
  else
    __info__ "Status: not running"
  fi
  __info__ "List of configuration files: "
  FILES=$(find "$DIR_OPENVPN" -iname "*.ovpn")
  COUNT=0
  for FILE in $FILES; do
    COUNT=$((COUNT + 1))
    __info__ "  ${COUNT}) $(basename "$FILE")"
  done

  #
  __info__ "LOG_FILE: ${LOG_FILE}"
  __info__ "PID_FILE: ${PID_FILE}"
fi
