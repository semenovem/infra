FROM debian:12.1-slim

ARG USER_ID=1001
ARG GROUP_ID=1001
ARG DOWNLOAD_PATH="http://repo.yandex.ru/yandex-disk/yandex-disk_latest_amd64.deb"

RUN apt update && apt -y install curl
RUN curl -o ya.deb -L ${DOWNLOAD_PATH} && dpkg -i ya.deb && rm ya.deb
RUN groupadd -g ${GROUP_ID} app && useradd -m -l -u ${USER_ID} -g app app

USER app
