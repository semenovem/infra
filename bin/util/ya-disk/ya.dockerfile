FROM curlimages/curl:8.4.0 as builder

ARG DOWNLOAD_PATH="http://repo.yandex.ru/yandex-disk/yandex-disk_latest_amd64.deb"
RUN curl -o /tmp/ya.deb -L ${DOWNLOAD_PATH}

FROM debian:12.1-slim

#ARG USER_ID=1001
#ARG GROUP_ID=1001

#RUN apt update && apt -y install curl
#RUN curl -o ya.deb -L ${DOWNLOAD_PATH} && dpkg -i ya.deb && rm /tmp/ya.deb

COPY --from=builder /tmp/ya.deb /tmp/ya.deb
RUN dpkg -i /tmp/ya.deb && rm /tmp/ya.deb
# RUN groupadd -g ${GROUP_ID} app && useradd -m -l -u ${USER_ID} -g app app

#USER app
