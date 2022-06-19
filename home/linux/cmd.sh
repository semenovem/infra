#!/bin/bash

#PS1='\[\e[0;32m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] \[\e[1;37m\]'

# source ~/_dev/environment/bash/image_magick

# todo doesn`t work on mac
# PS1="\e[0;36m\u@\h \W$ \e[m"

# http://es.tldp.org/COMO-INSFLUG/COMOs/Bash-Prompt-Como/Bash-Prompt-Como-5.html
# ps ajxf | awk '{ if($2 == $4) { if ($1 == 1) { print "\033[35m" $0"\033[0m"}  else print "\033[1;32m" $0"\033[0m" } else print $0 }'


#while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-29));date;tput rc;done &


#12. Поиск повторяющихся файлов
#Удобный способ поиска дубликатов файлов, при котором команда получает и сравнивает их хэш-значения.
#find -not -empty -type f -printf "%s
#" |  sort -rn |  uniq -d |  xargs -I{} -n1  find -type f -size {}c -print0 |  xargs -0  md5sum |  sort |  uniq -w32 --all-repeated=separate
