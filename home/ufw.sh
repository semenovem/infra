sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw status verbose
sudo ufw enable

# home
sudo ufw allow in on enp2s0 to any port 22
sudo ufw allow in on enp7s0 to any port 22

# srv,,,
sudo ufw allow 22
sudo ufw allow 1194
