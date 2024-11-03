


https://mindsers.blog/en/post/https-using-nginx-certbot-docker/

docker compose run --rm  certbot certonly --webroot --webroot-path /var/www/certbot/ --dry-run -d example.org

docker compose run --rm certbot renew



---------
про настройку nginx

https://ssl-config.mozilla.org/#server=nginx


sh -c "echo -n 'user:' >> /etc/nginx/.htpasswd"
sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"

