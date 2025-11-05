#!/bin/bash

# crontab
# CRONE_EXEC=y
# 0 1,9,17 * * * /bin/bash "/home/evg/_infra/dc/mini47/crone/crontab.sh"

[ "$CRONE_EXEC" = y ] && exec >> "/mnt/backup_vol/logs/mini47-fwd-check.log" 2>&1

log_prefix() {
    echo "[mini47][fwd][$(date +%m-%d_%H:%M)]"
}

echo "[INFO]$(log_prefix) check ssh forwarding"
bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[INFO]$(log_prefix) check ssh forwarding"

# Проверить, что интернет есть
if ! ping -c 2 ya.ru > /dev/null 2>&1; then
    echo "[WARN]$(log_prefix) no internet connecion"
    bash "/home/evg/_infra/bin/util/bot-evgio.sh" "[WARN]$(log_prefix) no internet connecion"
    exit 1
fi

OUT_MSG=

# $1 name of endpoint
fn_notify_msg() {
    echo "[ERRO]$(log_prefix) ssh forwarding to ${1} does not work: [${OUT_MSG}]"
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

  echo "[ERRO]$(log_prefix) no connect to [-p ${2} ${3}]: [${OUT_MSG}]"
  bash "/home/evg/_infra/bin/util/bot-evgio.sh" "$(fn_notify_msg "[-p ${2} ${3}]")"
  return 1
}

if ! fn_check -p 2022 forwardman@home.evgio.com; then
    if ! fn_is_verification; then
      sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh stop 'ssh-fwrd-home.conf'
      sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh start 'ssh-fwrd-home.conf'
  fi
fi

if ! fn_check -p 2122 forwardman@home.evgio.com; then
  if ! fn_is_verification; then
      sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh stop 'ssh-fwrd-home-srv1.conf'
      sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh start 'ssh-fwrd-home-srv1.conf'
  fi
fi

if ! fn_check -p 2257 forwardman@msk1.evgio.com; then
  if ! fn_is_verification; then
      sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh stop 'ssh-fwrd-msk1.conf'
      sh /home/evg/_infra/dc/mini47/systemctl/run-task.sh start 'ssh-fwrd-msk1.conf'
  fi
fi
