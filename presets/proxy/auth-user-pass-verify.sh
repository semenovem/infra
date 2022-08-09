#!/bin/sh

# auth-user-pass-verify "/etc/openvpn/auth-user-pass-verify.sh" via-env

PATH="/etc/openvpn/users.txt"
USER="${username} ${password}"

/usr/bin/grep -iE "^${USER}$" "$PATH" -q || exit 1

exit 0
