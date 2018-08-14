FROM ubuntu:18.04 as wireshark
LABEL maintainer="don@agilicus.com"

ENV DEBIAN_FRONTEND noninteractive

COPY pause.c /pause.c
# Going to build a static-linked dump-cap, rather than
# install wireshark-common in below. Saves 200MB.
# Used github.com mirror rather than https://code.wireshark.org/review/wireshark
# for speed.  The 1b3cedbc5fe5b9d8b454a10fcd2046f0d38a9f19 == tags/wireshark-2.6.2
# We do the fetch SHA rather than clone since the repo is big.
RUN apt-get update \
    && apt-get -y install --no-install-recommends git build-essential ca-certificates \
    && apt-get -y build-dep wireshark-common \
    && gcc -o /usr/local/bin/pause /pause.c

RUN mkdir -p wireshark/build \
    && cd wireshark \
    && git init \
    && git remote add origin https://github.com/wireshark/wireshark \
    && git fetch origin 1b3cedbc5fe5b9d8b454a10fcd2046f0d38a9f19 \
    && git reset --hard FETCH_HEAD
RUN cd wireshark/build \
    && cmake -DENABLE_STATIC=1 -DBUILD_dumpcap=ON \
             -DENABLE_LUA=OFF \
             -DENABLE_GNUTLS=OFF \
             -DENABLE_NGHTTP2=OFF \
             -DENABLE_SMI=OFF \
             -DENABLE_KERBEROS=OFF \
             -DENABLE_SBC=OFF \
             -DENABLE_SPANDSP=OFF \
             -DENABLE_BCG729=OFF \
             -DENABLE_LIBXML2=OFF \
             -DBUILD_wireshark=OFF \
             -DBUILD_tshark=OFF \
             -DBUILD_tfshark=OFF \
             -DBUILD_rawshark=OFF \
             -DBUILD_text2pcap=OFF \
             -DBUILD_mergecap=OFF \
             -DBUILD_reordercap=OFF \
             -DBUILD_editcap=OFF \
             -DBUILD_capinfos=OFF \
             -DBUILD_captype=OFF \
             -DBUILD_randpkt=OFF \
             -DBUILD_dftest=OFF \
             -DBUILD_corbaidl2wrs=OFF \
             -DBUILD_dcerpcidl2wrs=OFF \
             -DBUILD_xxx2deb=OFF \
             -DBUILD_androiddump=OFF \
             -DBUILD_sshdump=OFF \
             -DBUILD_ciscodump=OFF \
             -DBUILD_dpauxmon=OFF \
             -DBUILD_randpktdump=OFF \
             -DBUILD_udpdump=OFF \
             -DBUILD_sharkd=OFF  .. \
    && make -j $(getconf _NPROCESSORS_ONLN) dumpcap \
    && cp -r run/dumpcap /usr/local/bin/dumpcap \
    && chmod a=rx /usr/local/bin/dumpcap \
    && strip /usr/local/bin/dumpcap

FROM golang:1.10-stretch as crictl
RUN mkdir -p /go/bin /go/src/github.com/kubernetes-incubator \
    && cd /go/src/github.com/kubernetes-incubator \
    && git clone https://github.com/kubernetes-incubator/cri-tools \
    && cd cri-tools \
    && git checkout 3df9c005e3e812dfb933867ae31843bc61969f63 \
    && make \
    && make install

FROM ubuntu:18.04
COPY --from=wireshark /usr/local/bin/dumpcap /usr/local/bin/dumpcap
COPY --from=wireshark /usr/local/bin/pause /usr/local/bin/pause
COPY --from=crictl /usr/local/bin/crictl /usr/local/bin/crictl
ENV LANG en_CA.UTF-8
ENV LC_ALL en_CA.UTF-8

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        locales util-linux python3 hping3 fping oping \
        inetutils-ping iproute2 curl tcpdump libpcap0.8 libglib2.0-0 libnl-3-200 libnl-genl-3-200 libpcre3 zlib1g libcap2 gdb strace iptables \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_CA.UTF-8

CMD /usr/local/bin/pause
WORKDIR /root
