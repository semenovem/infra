#!/bin/sh

# mamual: 
# for config file:
# the configuration file should have its first comment specifying the service name for systemctl

# use run
func_help() {
  echo "use: \$1 [start|stop|state] \$2 [configuration file in the same directory]"
}

[ $# -eq 0 ] && func_help && exit 0

func_extract_service_name() {
    grep -m 1 -i '^#' "$1" | sed 's/^[#[:space:]]*//'
}

[ -z "$2" ] && echo "[ERRO] not passed \$2 - name of service" && exit 1

ROOT=$(dirname "$(echo "$0" | grep -E "^/" -q && echo "$0" || echo "$PWD/${0#./}")")
CONFIG_FILE="${ROOT}/$2"
[ ! -f "$CONFIG_FILE" ] && echo "[ERRO] \$2 not a file" && exit 1

SERVICE_NAME="$(func_extract_service_name "$CONFIG_FILE")" || exit 1
[ -z "$SERVICE_NAME" ] && echo "[ERRO] empty service name" && exit 1

UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}"

# operation ------------------------------------------
case "$1" in
    "start" | "stop" | "state" | "stat") ;;
    *) 
        echo "[ERRO] unknown command \$1=[$1]"  
        exit 1
    ;;
esac

# ------------------------------------------------------
case "$1" in
"start")
    echo "<<< START ${SERVICE_NAME} >>>"

    cp "$CONFIG_FILE" "$UNIT_FILE" && \
    systemctl daemon-reload && \
    systemctl start "$SERVICE_NAME" && \
    systemctl --no-pager status "$SERVICE_NAME" &&
    systemctl enable "$SERVICE_NAME"
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
