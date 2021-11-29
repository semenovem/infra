#!/bin/bash


exit 0


sudo apt-get upgrade

sudo apt-get update
sudo apt-get install squid squid-common
sudo service squid start

sudo systemctl enable squid  # автозапуск


sudo service squid restart


# squid.conf
#
# http_port 26824


# Журнал доступа к Squid: /var/log/squid/access.log
# Журнал кэша Squid: /var/log/squid/cache.log

# установленные значения в файле конфигурации
grep -Eiv '(^#|^$)' /etc/squid/squid.conf


forwarded_for

# Порты
# home server
13389 # ssh -R

