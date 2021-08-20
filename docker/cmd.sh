#!/bin/bash

exit 0

# redirecting logs to a file
docker logs containername >& logs/myFile.log

# how much space does docker take
docker system df


# Manage Docker as non-root user
# ubuntu
sudo groupadd docker
sudo usermod -aG docker "$USER"

sudo systemctl restart docker


# docker swarm
docker node ls -q | xargs docker node inspect \
  -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ .Spec.Labels }}'


watch -cd -n 1 \
    'docker service ls -f name=iata --format "table {{.Name}}\t{{.Replicas}}"'
# 'docker service ls --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}\t{{.Ports}}"'
