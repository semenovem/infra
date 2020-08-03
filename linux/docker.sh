

# https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot

# Manage Docker as non-root user
# ubuntu
sudo groupadd docker
sudo usermod -aG docker "$USER"

#reboot
newgrp docker

# can be checked
docker run hello-world