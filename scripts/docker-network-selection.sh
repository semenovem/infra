#!/bin/bash

# Показывает список доступных сетей docker
# и дает возможность выбрать
# Результат - название сети выведем в консоль
# [$1] - фильтр частичное или полное название сети
# если найдена только одна сеть, выбора не будет, на этом работат скрипта завершится
# использование в Makefile:
#
#	  @$(eval NETWORK=$(shell bash docker-network-selection.sh))
#	  @echo "\n=> NETWORK=$(NETWORK)"
#

BANNER="############################################################
# Выбор docker сети                                        #
############################################################"

ITEMS=$(docker network ls -f driver=overlay | tail -n +2 | awk '{print $2}')
FILTER=$1

# фильтр сетей
T=""
for it in $ITEMS; do
  [ "$FILTER" ] && [ $(echo $it | grep -i "$FILTER") ] && T="${T}${it} "
  [ $(echo $it | grep -i -v "ingress") ] && T="${T}${it} "
done
T=$(echo "$T" | xargs)
[ "$T" ] && ITEMS=$T

COUNT=0
for it in $ITEMS; do
  ((COUNT++))
done

[ -z "$ITEMS" ] && echo "No networks" && return 1

# Если нашли только одну сеть - используем ее и пропускаем шаг выбора
[ "$COUNT" -eq 1 ] && echo "$ITEMS" && exit 0

# Формируем список сетей и сообщение для пользователя при выборе
TMP=$(mktemp)
[ $? -ne 0 ] && exit 1

echo "" >>"$TMP"

i=0
for it in $ITEMS; do
  ((i++))
  echo "${i}) $it " >>"$TMP"
done
echo "List of docker networks: Choose a number [1 - $i] ? " >>"$TMP"

# Покажем выбор сетей
REG_NUM='^[0-9]+$'
NAME=
LEN=1
[ "$COUNT" -gt 10 ] && LEN=2

MSG_SELECT="${BANNER}
$(cat $TMP)"

while true; do
  read -rn $LEN -p "$MSG_SELECT" ANSWER
  echo

  if [ "$ANSWER" ] && [[ $ANSWER =~ $REG_NUM ]]; then
    i=0
    for it in $ITEMS; do
      ((i++))
      [ "$i" -eq "$ANSWER" ] && NAME=$it && break
    done
  fi

  [ "$NAME" ] && break

  MSG_SELECT="$(cat $TMP)"
done

echo "$NAME"
