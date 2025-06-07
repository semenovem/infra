
apt-get install ntp

systemctl status ntpsec.service
ntpq -p

/etc/ntpsec/ntp.conf


restrict 4 default kod notrap nomodify nopeer noquery
restrict 6 default kod notrap nomodify nopeer noquery

restrict 192.168.0.0 mask 255.255.0.0 nomodify notrap
