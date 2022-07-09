#!/bin/bash

_BIN_=$(dirname "$([[ $0 == /* ]] && echo "$0" || echo "$PWD/${0#./}")")
_CONFIG_FILE_="${_BIN_}/vpn-config.ovpn"
_MONITOR_PORT_=21021
_SSH_FORWARD_=
_LOG_FILE_="${_BIN_}/openvpn-client.log"
_PID_FILE_="${_BIN_}/openvpn-client.pid"
_OPER_=$1
_CFG_PROTO_=tcp

SOCKS_HOST="127.0.0.1"
SOCKS_PORT="1080"

PORT="443"

SSH_CONN_NAME="spb"
HOST="spb.evgio.dev"

SSH_CONN_NAME="rr4"
HOST="rr4.evgio.dev"

# ------------------------------------
# ------------------------------------
# ------------------------------------
_YELLOW_='\033[1;33m'
_LIGHT_BLUE_='\033[1;34m'
_RED_='\033[0;31m'
_GREEN_='\033[0;32m'
_NC_='\033[0m'

info() {
  echo -e "${_GREEN_}[INFO][conn-vpn]${_NC_} $*"
}

err() {
  echo -e "${_RED_}[ERRO][conn-vpn]${_NC_} $*"
}

function pidSsh {
  local pid
  pid=$(ps -aux | grep autossh | grep -v grep | grep -iE "${SOCKS_HOST}.+${SOCKS_PORT}.+${SSH_CONN_NAME}" | awk '{print $2}')
  [ -z "$pid" ] && return 1
  echo "$pid"
}

function pidVpn {
  local pid
  pid=$(ps -aux | grep -Ei '(sudo)?.*openvpn.*\-\-config.*[^grep]' | awk '{print $2}')
  [ -z "$pid" ] && return 1
  echo "$pid"
}

function disconn {
  local pid
  pid=$(pidVpn) && sudo kill -2 "$pid"
  [ -n "$_SSH_FORWARD_" ] && pid=$(pidSsh) && kill -2 "$pid"
}

function connSsh {
  autossh -f -M "$_MONITOR_PORT_" \
    -o "StrictHostKeyChecking=false" \
    -o "ServerAliveInterval 60" \
    -o "ServerAliveCountMax 3" \
    -N -D "${SOCKS_HOST}:${SOCKS_PORT}" "$SSH_CONN_NAME"
}

fnShowLog() {
  sudo tail -f "$_LOG_FILE_"
}

# -------------------------------------------------------------
case "$_OPER_" in
"log") fnShowLog ;;

"stop" | "down")
  info "stop"
  disconn
  ;;

"start")
  info "start"

  if [ -n "$_SSH_FORWARD_" ]; then
    while true; do
      pidSsh 1>/dev/null && break
      connSsh
      sleep 3
      info "try connect to ssh.."
    done
  fi

  #  --status file n Write operational status to file every n seconds.

  pidVpn 1>/dev/null
  if [ $? -ne 0 ]; then
    if [ -n "$_SSH_FORWARD_" ]; then
      sudo openvpn \
        --config "$_CONFIG_FILE_" \
        --socks-proxy "$SOCKS_HOST" "$SOCKS_PORT" \
        --remote "$HOST" "$PORT" \
        --proto "$_CFG_PROTO_" \
        --route "$HOST" 255.255.255.255 net_gateway \
        --route-up "/bin/ip route del 127.0.0.1" \
        --log "$_LOG_FILE_" \
        --writepid "$_PID_FILE_" \
        --auth-nocache \
        --connect-retry 10 60 \
        --daemon
    else
      sudo openvpn \
        --config "$_CONFIG_FILE_" \
        --remote "$HOST" "$PORT" \
        --proto "$_CFG_PROTO_" \
        --log "$_LOG_FILE_" \
        --writepid "$_PID_FILE_" \
        --auth-nocache \
        --connect-retry 10 60 \
        --daemon
    fi

    fnShowLog
  else
    info "already launched"
  fi
  ;;

*)
  info "SSH_CONN_NAME  = $SSH_CONN_NAME"
  info "HOST           = $HOST"
  info "CFG_PROTO      = $_CFG_PROTO_"

  info ">>> status VPN connect = "$(pidVpn 1>/dev/null && echo "yes" || echo "no")
  [ -n "$_SSH_FORWARD_" ] && ps -aux | grep autossh | grep -v grep
  ps -aux | grep "openvpn" | grep "\--config" | grep -v grep
  ;;
esac
