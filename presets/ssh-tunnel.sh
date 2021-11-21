exit

# https://qastack.ru/ubuntu/947841/start-autossh-on-system-startup
# http://rus-linux.net/MyLDP/sec/reverse-SSH-tunnel.html

# srv-home >>> relay-server
# -fN флаг для работы в фоне
ssh -R 2022:localhost:22 root@89.223.122.250

# проверка настройки обратного ssh
# relay-server
sudo netstat -nap | grep 2022

# Подключение

# контроль ssh туннеля
# -fN флаг для работы в фоне
autossh -M 2021 \
  -o "PubkeyAuthentication=yes" \
  -o "StrictHostKeyChecking=false" \
  -o "PasswordAuthentication=no" \
  -o "ServerAliveInterval 60" \
  -o "ServerAliveCountMax 3" \
  -R 2022:localhost:22 root@89.223.122.250
