#!/bin/sh

# use run with sudo
func_help() {
  echo "use: \$1 [start|stop|state|list] \$2 [configuration file in the same directory]"
}

[ $# -eq 0 ] && func_help && exit 0

# define command----------------------------------------
case "$1" in
    "start" | "stop" | "state" | "stat") ;;
    "list") 
        systemctl list-units --type=service | grep ssh-fwrd
        exit 0
    ;;
    *) 
        echo "[ERRO] unknown command \$1=[$1]"  
        exit 1
    ;;
esac

[ -z "$2" ] && echo "[ERRO] not passed \$2 - name of service" && exit 1

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
CONFIG_FILE="${ROOT}/$2"
[ ! -f "$CONFIG_FILE" ] && echo "[ERRO] \$2 not a file" && exit 1

SERVICE_NAME="${2%%.*}.service"
[ -z "$SERVICE_NAME" ] && echo "[ERRO] empty service name" && exit 1

UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}"

# ------------------------------------------------------
case "$1" in
"start")
    echo "<<< START ${SERVICE_NAME} >>>"

    cp "$CONFIG_FILE" "$UNIT_FILE" && \
    systemctl daemon-reload && \
    systemctl start "$SERVICE_NAME" && \
    systemctl enable "$SERVICE_NAME" &&
    systemctl --no-pager status "$SERVICE_NAME"
;;

"stop")
    echo "<<< STOP ${SERVICE_NAME} >>>" 

    systemctl stop "$SERVICE_NAME" && \
    systemctl disable "$SERVICE_NAME" && \
    rm -f "$UNIT_FILE" && \
    systemctl reset-failed; \
    systemctl daemon-reload
;;

*) systemctl --no-pager status "$SERVICE_NAME" ;;
esac
