#!/bin/bash

# crontab
# /bin/bash "/home/evg/_infra/dc/mini47/crone/crontab.sh"

# Проверить, что интернет есть
if ! ping -c 2 ya.ru > /dev/null 2>&1; then
    echo "[WARN][$0] no internet connecion"
    bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[WARN] mini47 no internet connecion"
    exit 1
fi

OUT_MSG=

# $1 name of endpoint
fn_notify_msg() {
    echo "[ERRO][mini47] ssh forwarding to ${1} does not work: [${OUT_MSG}]"
}

fn_is_verification() {
    echo "$OUT_MSG" | grep -q "Host key verification failed"
}

# $@ ssh conection params
fn_check() {
    OUT_MSG="$(ssh "$@" -i /home/evg/.ssh/id_ecdsa 'ssh -p 4022 test13579@localhost hostname' 2>&1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')" 
    if echo "$OUT_MSG" | grep -q "Permission denied"; then
        return 0
    fi

    echo "[ERRO][$0] no connect to [-p ${2} ${3}]: [${OUT_MSG}]"
    return 1
}

if ! fn_check -p 2022 forwardman@home.evgio.com; then 
    bash "/home/evg/_infra/bin/util/bot-evgio.sh" "$(fn_notify_msg "home")"
fi


if ! fn_check -p 2122 forwardman@home.evgio.com; then 
    if ! fn_is_verification; then
        sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh stop 'ssh-fwrd-home-srv1.conf'
        sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh start 'ssh-fwrd-home-srv1.conf'
    fi
fi

if ! fn_check -p 2257 forwardman@msk1.evgio.com; then 
    bash "/home/evg/_infra/bin/util/bot-evgio.sh" "$(fn_notify_msg "msk1")"

    if ! fn_is_verification; then
        sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh stop 'ssh-fwrd-msk1.conf'
        sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh start 'ssh-fwrd-msk1.conf'
    fi
fi
