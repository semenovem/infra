FROM debian:11.6

ARG USER_ID=1001
ARG GROUP_ID=1001

RUN apt update && apt -y install curl
RUN curl -o ya.rpm -L http://repo.yandex.ru/yandex-disk/yandex-disk_latest_amd64.deb && \
  dpkg -i ya.rpm && \
  rm ya.rpm

RUN groupadd -g ${GROUP_ID} app \
    && useradd -m -l -u ${USER_ID} -g app app

USER app


#
#FROM fedora:38
#
#ARG USER_ID=1001
#ARG GROUP_ID=1001
#
#RUN curl -o ya.rpm -L http://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm && \
#  rpm -ivh ya.rpm && \
#  rm ya.rpm
#
#RUN groupadd -g ${GROUP_ID} app \
#    && useradd -m -l -u ${USER_ID} -g app app
#
#USER app
