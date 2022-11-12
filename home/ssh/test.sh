#!/bin/sh


cp "workstation.txt" "workstation-copy.txt"

sed 's/#.*//g' "workstation-copy.txt"
#export $(cat ./file.env | sed 's/#.*//g' | xargs)

exit

while read ROW; do

  echo ">> $ROW" | grep -Eio '^[^#]+'

#  echo "$row" | grep -q -iE '^#' && continue
#  [ -z "$row" ] && continue
#
#  echo "$row" | grep -q -iE '^hosts'
#  if [ $? -eq 0 ]; then
#    defaultHosts=$(echo "$row" | sed "s/^hosts\s*//i")
#    continue
#  fi

#  echo "$row" | grep -q -iE "^${__HOSTNAME__}" || continue
#
#  count=0
#  hosts=
#  ports=
#  for it in $row; do
#    ((count++))
#    [ "$count" -eq 1 ] && continue
#    echo "$it" | grep ":" -q && ports="${ports} ${it}" || hosts="${hosts} ${it}"
#  done
#
#  [ -z "$hosts" ] && hosts="$defaultHosts"
#
#  for host in $hosts; do
#    map["$host"]+="$ports"
#  done
done <"workstation.txt"
