

про настройку nginx

https://ssl-config.mozilla.org/#server=nginx


sh -c "echo -n 'user:' >> /etc/nginx/.htpasswd"
sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"

