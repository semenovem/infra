FROM fedora:38

RUN #curl -LO https://repo.yandex.ru/yandex-disk/rpm/stable/x86_64/yandex-disk-0.1.6.1080-1.fedora.x86_64.rpm
RUN curl -o ya.rpm -L http://repo.yandex.ru/yandex-disk/yandex-disk-latest.x86_64.rpm && \
  rpm -ivh ya.rpm && \
  rm ya.rpm

CMD bash
