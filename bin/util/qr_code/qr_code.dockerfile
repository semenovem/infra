FROM ubuntu:22.04

RUN apt update && apt -y install qrencode zbar-tools && apt clean
