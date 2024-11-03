FROM debian:12.7-slim

RUN apt -y update && \
  apt -y install nextcloud-desktop-cmd && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*
