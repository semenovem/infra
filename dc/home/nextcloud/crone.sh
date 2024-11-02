#!/bin/sh

while true; do
  sleep 600

  echo "[INFO] maintains nextcloud via crone start"

  # скрипт нужно запускать от пользователя www-data
  usermod -s /bin/sh www-data || continue

  # выполнение регулярных задач обслуживания в nextcloud
  # https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html
  runuser -l www-data -c "php -f /var/www/html/cron.php"
  usermod -s /usr/sbin/nologin www-data
done
