FROM alpine:3.20.3

RUN apk add --no-cache --update \
  samba-common-tools \
  samba-client \
  samba-server \
  && rm -rf /var/cache/apk/*
