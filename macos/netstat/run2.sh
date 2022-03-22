#!/bin/bash







#exit


# удаление локальных маршрутов
LIST=$(netstat -nr | grep 192. | grep utun | awk '{print $1}')

for addr in $LIST; do
  echo "deleting: $addr  $(sudo route -n delete "$addr")"
#  sudo route -n delete "$addr"
done


exit 0

#!/bin/sh
# netstat -nr
export IP=$(netstat -nr | grep utun3 | head -1 | awk "{print $2}")
for OUTPUT in $(netstat -nr | grep utun3 | awk "{print $1}")
do
    sudo route -n delete $OUTPUT        $IP
done
