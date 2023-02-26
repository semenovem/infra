FROM centos:centos7

RUN yum -y update && \
    yum -y install epel-release &&  \
    yum -y install openvpn easy-rsa &&  \
    yum -y clean all

ENV PATH="/usr/share/easy-rsa/3:${PATH}"
