FROM centos:centos8

#ENV LC_ALL=C

#WORKDIR /etc/yum.repos.d
#RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
#RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
#RUN yum -y install curl

RUN curl -o ya.rpm -L http://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm && \
  rpm -ivh ya.rpm && \
  rm ya.rpm

CMD bash



#RUN addgroup --system app && adduser --system --group app
RUN #addgroup --gid 1001 --system app && \
#    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app
#USER app

# ------------------------------
FROM fedora:38

RUN #curl -LO https://repo.yandex.ru/yandex-disk/rpm/stable/x86_64/yandex-disk-0.1.6.1080-1.fedora.x86_64.rpm
RUN curl -o ya.rpm -L http://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm && \
  rpm -ivh ya.rpm && \
  rm ya.rpm

CMD bash



#RUN addgroup --system app && adduser --system --group app
RUN #addgroup --gid 1001 --system app && \
#    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app
#USER app
