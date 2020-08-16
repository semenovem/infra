#!/usr/bin/expect -f
#
# Usage: mount_yadisk <node> <username> <password>
# https://qna.habr.com/q/62740


#!/bin/bash
# https://webdav.yandex.ru


exit


if {$argc!=3} then {
    send_tty "Usage: mount_yadisk <node> <username> <password>\n"
    exit 1
}

set timeout 15
set node [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
log_user 0

if {!([file exists "$node"])} then {
    exec mkdir "$node"
}

spawn mount_webdav -i -s -v "Yandex.Disk" "https://webdav.yandex.ru:443" "$node"
expect {
    "Username:" { send "$username\n"; exp_continue }
    "Password:" { send "$password\n" }
}
