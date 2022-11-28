#!/bin/bash

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
. "${ROOT}/../_lib/core.sh" || exit 1

_SELF_NAME_="conn-vpn"
_MONITOR_PORT_=21021

_CONFIG_FILE_="${HOME}/vpn-config.ovpn"
CONFIG_FILE_HOME="${HOME}/vpn-config-home.ovpn"

_LOG_FILE_="${HOME}/openvpn-client.log"
_PID_FILE_="${HOME}/openvpn-client.pid"

[ ! -f "$_CONFIG_FILE_" ] &&
  echo "[ERRO] нет файла конфиграции '$_CONFIG_FILE_'" &&
  exit 1

_SERVER_NAMES="spb msk1 rr4 kz2"
_VPN_PORTS_="443 33440"

TO_HOME= # подключение домой
_VPN_HOST_=
_VPN_PORT_=443
_PROTOCOL_="tcp"

_SSH_FORWARD_=
_SSH_HOST_=

_OPER_=
_OPENVPN_ARGS_=
_IS_VPN_START_=

SOCKS_HOST="127.0.0.1"
SOCKS_PORT="1080"

# ------------------------------------
# ------------------------------------
# ------------------------------------
help() {
  __info__ "use [port] [tcp|udp (default = tcp)] [${_SERVER_NAMES}] EXAMPLE: ./conn-vpn.sh 33440 udp msk1"
}

pidSsh() {
  local pid
  pid=$(ps -aux | grep autossh | grep -v grep | grep -iE "${SOCKS_HOST}.+${SOCKS_PORT}.+${SSH_CONN_NAME}" | awk '{print $2}')
  [ -z "$pid" ] && return 1
  echo "$pid"
}

pidVpn() {
  local pid
  pid=$(ps -aux | grep -Ei '(sudo)?.*openvpn.*\-\-config.*[^grep]' | awk '{print $2}')
  [ -z "$pid" ] && return 1
  echo "$pid"
  return 0
}

isVpnWork() {
  [ -n "$(pidVpn)" ] && return 0 || return 1
}

disconnect() {
  [ -n "$1" ] || __info__ "disconn"
  pid=$(pidVpn) && sudo kill -SIGTERM "$pid"
  [ -n "$_SSH_FORWARD_" ] && pid=$(pidSsh) && kill -SIGTERM "$pid"
  sleep 1
}

connSsh() {
  autossh -f -M "$_MONITOR_PORT_" \
    -o "StrictHostKeyChecking=false" \
    -o "ServerAliveInterval 60" \
    -o "ServerAliveCountMax 3" \
    -N -D "${SOCKS_HOST}:${SOCKS_PORT}" "$SSH_CONN_NAME"
}

fnShowLog() {
  sudo tail -f "$_LOG_FILE_"
}

check() {
  ERR=
  [ -z "$_VPN_HOST_" ] && [ -z "$TO_HOME" ] && ERR=1 && __err__ "empty vpn host"

  if [ -n "$__SSH_FORWARD_" ]; then
    #     TODO проверки данных для ssh подключения
    echo "work in progress"
  fi

  [ "$ERR" ] && __err__ "break and exit 1" && help && return 1
  return 0
}

buildCmd() {
  _OPENVPN_ARGS_="${_OPENVPN_ARGS_} $*"
}

connect() {
  pidVpn 1>/dev/null && __info__ "already launched" && return 0

  check || return 1

  if [ -n "$_SSH_FORWARD_" ]; then
    while true; do
      pidSsh 1>/dev/null && break
      connSsh
      sleep 3
      __info__ "try connect to ssh.."
    done
  fi

  if [ -n "$TO_HOME" ]; then
    buildCmd --config "$CONFIG_FILE_HOME" \
      --log "$_LOG_FILE_" \
      --writepid "$_PID_FILE_" \
      --auth-nocache \
      --connect-retry 10 60 \
      --daemon
  else
    buildCmd --config "$_CONFIG_FILE_" \
      --log "$_LOG_FILE_" \
      --writepid "$_PID_FILE_" \
      --remote "$_VPN_HOST_" "$_VPN_PORT_" \
      --proto "$_PROTOCOL_" \
      --auth-nocache \
      --connect-retry 10 60 \
      --daemon
  fi

  if [ -n "$_SSH_FORWARD_" ]; then
    buildCmd --socks-proxy "$SOCKS_HOST" "$SOCKS_PORT" \
      --route "$HOST" 255.255.255.255 net_gateway \
      --route-up "/bin/ip route del 127.0.0.1"
  fi

  __debug__ "args for: ${_OPENVPN_ARGS_}"
  sudo openvpn $_OPENVPN_ARGS_
  fnShowLog
}

# =========================================================
# =========================================================
for p in $@; do
  case "$p" in
  "udp") _PROTOCOL_="udp" ;;
  "tcp") _PROTOCOL_="tcp" ;;
  "start" | "connect" | "up") _OPER_="connect" ;;
  "stop" | "disconnect" | "down") _OPER_="disconnect" ;;
  "home")
    TO_HOME=1
    _VPN_HOST_="home"
    ;;
  "log") _OPER_="log" ;;
  "status") _OPER_="status" ;;
  "socks") _SSH_FORWARD_="1" ;;
  "-h" | "h" | *"help") help ;;
  *)
    echo "$p" | grep -E '^[0-9]+$' -q && _VPN_PORT_="$p" && continue

    stop=
    for it in $_SERVER_NAMES; do
      [ "$it" = "$p" ] && _VPN_HOST_="${p}.evgio.dev"
      _SSH_HOST_="$p" && stop=0
    done
    [ "$stop" ] && continue

    __err__ "argument not defined: '$p'"
    ;;
  esac
done

isVpnWork && _IS_VPN_START_=1

__debug__ "_IS_VPN_START_ = ${_IS_VPN_START_}"
__debug__ "_VPN_HOST_     = ${_VPN_HOST_}"
__debug__ "_VPN_PORT_     = ${_VPN_PORT_}"
__debug__ "_PROTOCOL_     = ${_PROTOCOL_}"
__debug__ "_SSH_FORWARD_  = ${_SSH_FORWARD_}"
__debug__ "_SSH_HOST_     = ${_SSH_HOST_}"
__debug__ "_OPER_         = ${_OPER_}"

if [ -n "$_VPN_HOST_" ] && [ -z "$_OPER_" ]; then
  [ -n "$_IS_VPN_START_" ] && disconnect "quiet"
  _OPER_="connect"
fi

# =========================================================
# =========================================================
case "$_OPER_" in
"log") fnShowLog ;;
"disconnect") disconnect ;;
"connect")
  [ -z "$_VPN_HOST_" ] && __err__ "not passed vpn host" && help && exit 1
  connect

  ;;
*)
  __info__ ">>> status VPN connect = "$(pidVpn 1>/dev/null && echo "yes" || echo "no")
  [ -n "$_SSH_FORWARD_" ] && ps -aux | grep autossh | grep -v grep
  ps -aux | grep "openvpn" | grep "\--config" | grep -v grep
  ;;
esac
