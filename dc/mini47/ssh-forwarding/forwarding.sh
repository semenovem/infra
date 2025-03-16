#!/bin/sh

srv_name="ssh-fwrd-socks-eu1.service"
unit_file="/etc/systemd/system/${srv_name}"

# ------------------------------------------------------
case "$1" in
"start")
    echo "<<< START >>>" 

    cp "/home/evg/_infra/dc/mini47/ssh-forwarding/ssh-fwrd-socks-eu1.conf" \
        "$unit_file" && \
    systemctl daemon-reload && \
    systemctl start "$srv_name" && \
    systemctl status "$srv_name" &&
    systemctl enable "$srv_name"
;;

"stop")
    echo "<<< STOP >>>" 

    systemctl stop "$srv_name" && \
    systemctl disable "$srv_name" && \
    rm -f "$unit_file" && \
    systemctl reset-failed; \
    systemctl daemon-reload
;;

*) systemctl status "$srv_name" ;;
esac
