#!/bin/bash

_BIN_=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")
_SELF_NAME_="conn-vpn"
_MONITOR_PORT_=21021

_CONFIG_FILE_="${HOME}/vpn-config.ovpn"
_LOG_FILE_="${HOME}/openvpn-client.log"
_PID_FILE_="${HOME}/openvpn-client.pid"

[ ! -f "$_CONFIG_FILE_" ] &&
  echo "[ERRO] нет файла конфиграции '$_CONFIG_FILE_'" &&
  exit 1

_SERVER_NAMES="spb msk1 rr4"
_VPN_PORTS_="443 33440"

_VPN_HOST_=
_VPN_PORT_=443
_PROTOCOL_="tcp"

_SSH_FORWARD_=
_SSH_HOST_=

_OPER_=
_OPENVPN_ARGS_=
_DEBUG_=
_IS_VPN_START_=

SOCKS_HOST="127.0.0.1"
SOCKS_PORT="1080"

# ------------------------------------
# ------------------------------------
# ------------------------------------
_YELLOW_='\033[1;33m'
_LIGHT_BLUE_='\033[1;34m'
_RED_='\033[0;31m'
_GREEN_='\033[0;32m'
_RED_='\033[0;31m'
_GREEN_='\033[0;32m'
_BLUE_='\033[0;34m'
_PURPLE_='\033[0;35m'
_CYAN_='\033[0;36m'
_LIGHT_GRAY_='\033[0;37m'
_DARK_GRAY_='\033[1;30m'
_LIGHT_RED_='\033[1;31m'
_LIGHT_GREEN_='\033[1;32m'
_NC_='\033[0m'

info() {
  echo -e "${_GREEN_}[INFO][${_SELF_NAME_}]${_NC_} $*"
}

debug() {
  [ -z "$_DEBUG_" ] && return
  echo -e "${_DARK_GRAY_}[DEBU][${_SELF_NAME_}] $*${_NC_}"
}

err() {
  echo -e "${_RED_}[ERRO][${_SELF_NAME_}] $*${_NC_}"
}

help() {
  info "${_CYAN_}use [port] [tcp|udp (default = tcp)] [${_SERVER_NAMES}] EXAMPLE: ./conn-vpn.sh 33440 udp msk1${_NC_}"
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
  [ -n $1 ] || info "disconn"
  pid=$(pidVpn) && sudo kill -2 "$pid"
  [ -n "$_SSH_FORWARD_" ] && pid=$(pidSsh) && kill -2 "$pid"
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
  [ -z "$_VPN_HOST_" ] && ERR=1 && err "empty vpn host"

  if [ -n "$__SSH_FORWARD_" ]; then
    #     TODO проверки данных для ssh подключения
    echo "work in progress"
  fi

  [ "$ERR" ] && err "break and exit 1" && help && return 1
  return 0
}

buildCmd() {
  _OPENVPN_ARGS_="${_OPENVPN_ARGS_} $*"
}

connect() {
  [ -n $1 ] || info "start"

  pidVpn 1>/dev/null && info "already launched" && return 0

  check || return 1

  if [ -n "$_SSH_FORWARD_" ]; then
    while true; do
      pidSsh 1>/dev/null && break
      connSsh
      sleep 3
      info "try connect to ssh.."
    done
  fi

  buildCmd --config "$_CONFIG_FILE_" \
    --log "$_LOG_FILE_" \
    --writepid "$_PID_FILE_" \
    --remote "$_VPN_HOST_" "$_VPN_PORT_" \
    --proto "$_PROTOCOL_" \
    --auth-nocache \
    --connect-retry 10 60 \
    --daemon

  if [ -n "$_SSH_FORWARD_" ]; then
    buildCmd --socks-proxy "$SOCKS_HOST" "$SOCKS_PORT" \
      --route "$HOST" 255.255.255.255 net_gateway \
      --route-up "/bin/ip route del 127.0.0.1"
  fi

  debug "args for: ${_OPENVPN_ARGS_}"
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
  "log") _OPER_="log" ;;
  "status") _OPER_="status" ;;
  "socks") _SSH_FORWARD_="1" ;;
  "-h" | "h" | *"help") help ;;
  "-v" | "v" | *"debug" | *"verbose") _DEBUG_=1 ;;
  *)
    echo "$p" | grep -E '^[0-9]+$' -q && _VPN_PORT_="$p" && continue

    stop=
    for it in $_SERVER_NAMES; do
      [ "$it" = "$p" ] && _VPN_HOST_="${p}.evgio.dev"
      _SSH_HOST_="$p" && stop=0
    done
    [ "$stop" ] && continue

    err "argument not defined: '$p'"
    ;;
  esac
done

isVpnWork && _IS_VPN_START_=1

debug "_IS_VPN_START_ = ${_IS_VPN_START_}"
debug "_VPN_HOST_     = ${_VPN_HOST_}"
debug "_VPN_PORT_     = ${_VPN_PORT_}"
debug "_PROTOCOL_     = ${_PROTOCOL_}"
debug "_SSH_PORT_     = ${_SSH_PORT_}"
debug "_SSH_FORWARD_  = ${_SSH_FORWARD_}"
debug "_SSH_HOST_     = ${_SSH_HOST_}"
debug "_OPER_         = ${_OPER_}"

if [ -n "$_VPN_HOST_" ]; then
  if [ -z "$_OPER_" ]; then
    [ -n "$_IS_VPN_START_" ] && disconnect "quiet"
    _OPER_="connect"
  fi
fi

# =========================================================
# =========================================================
case "$_OPER_" in
"log") fnShowLog ;;
"disconnect") disconnect ;;
"connect")
  [ -z "$_VPN_HOST_" ] && err "not passed vpn host" && help && exit 1
  connect

  ;;
* | "status")
  info ">>> status VPN connect = "$(pidVpn 1>/dev/null && echo "yes" || echo "no")
  [ -n "$_SSH_FORWARD_" ] && ps -aux | grep autossh | grep -v grep
  ps -aux | grep "openvpn" | grep "\--config" | grep -v grep
  ;;
esac
