#!/bin/bash

# remove images without tag and repo
echo "[X] Removing images without repo:tags"
docker rmi $(docker images -q -a | xargs docker inspect --format='{{.Id}}{{range $rt := .RepoTags}} {{$rt}} {{end}}' | grep -v '/' | grep -v '[a-z]:.*')

# remove unused images
echo "[X] Removing images"
docker rmi $(docker images --filter='dangling=true' -q --no-trunc)

# remove unused volumes
echo "[X] Removing volumes"
docker volume rm $(docker volume ls -q --filter='dangling=true')

# truncate dockerd logs
truncate -s 0 /app/docker/logs/dockerd.log
