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

# $@ ssh conection params
fn_check() {
    OUT_MSG="$(ssh "$@" -i /home/evg/.ssh/id_ecdsa 'ssh -p 4022 evg@localhost hostname' 2>&1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')" 
    if ! echo "$OUT_MSG" | grep -q "Permission denied"; then
        echo "[ERRO][$0] no connect to $3: [${OUT_MSG}]"
        return 1
    fi
}

if ! fn_check -p 2022 forwardman@home.evgio.com; then 
    bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[ERRO] ssh forwarding to home does not work: [${OUT_MSG}]"
fi


if ! fn_check -p 2257 forwardman@msk1.evgio.com; then 
    :
fi
