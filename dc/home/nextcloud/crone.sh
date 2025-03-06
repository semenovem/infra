#!/bin/sh

echo "[INFO][$(date)] start"

while true; do
  sleep 60

  echo "[INFO][$(date)] maintains nextcloud via crone start"

  # скрипт нужно запускать от пользователя www-data
  # https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html
  su www-data -s /bin/bash -c "php -f /var/www/html/cron.php"

  echo "[INFO][$(date)] maintains nextcloud via crone end"

  sleep 3600
done
