FROM ubuntu:18.04
LABEL maintainer="don@agilicus.com"

ENV DEBIAN_FRONTEND noninteractive

ENV LANG en_CA.UTF-8
ENV LC_ALL en_CA.UTF-8

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        locales python3 hping3 fping oping inetutils-ping iproute2 curl tcpdump \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_CA.UTF-8

WORKDIR /root
