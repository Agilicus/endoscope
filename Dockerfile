FROM ubuntu:18.04 as wireshark
LABEL maintainer="don@agilicus.com"

ENV DEBIAN_FRONTEND noninteractive

# Going to build a static-linked dump-cap, rather than
# install wireshark-common in below. Saves 200MB.
# Used github.com mirror rather than https://code.wireshark.org/review/wireshark
# for speed.  The 1b3cedbc5fe5b9d8b454a10fcd2046f0d38a9f19 == tags/wireshark-2.6.2
# We do the fetch SHA rather than clone since the repo is big.
RUN apt-get update \
    && apt-get -y install --no-install-recommends git build-essential ca-certificates \
    && apt-get -y build-dep wireshark-common

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
    && make -j $(getconf _NPROCESSORS_ONLN) \
    && make install

#dumpcap is /usr/local/bin/dumpcap
#root@539adc5e6efa:~/wireshark/build# ldd /usr/local/bin/dumpcap
#	linux-vdso.so.1 (0x00007ffe94ff6000)
#	libpcap.so.0.8 => /usr/lib/x86_64-linux-gnu/libpcap.so.0.8 (0x00007fba19143000)
#	libcap.so.2 => /lib/x86_64-linux-gnu/libcap.so.2 (0x00007fba18f3d000)
#	libglib-2.0.so.0 => /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0 (0x00007fba18c27000)
#	libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007fba18a0a000)
#	libnl-genl-3.so.200 => /lib/x86_64-linux-gnu/libnl-genl-3.so.200 (0x00007fba18804000)
#	libnl-3.so.200 => /lib/x86_64-linux-gnu/libnl-3.so.200 (0x00007fba185e4000)
#	libgmodule-2.0.so.0 => /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0 (0x00007fba183e0000)
#	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fba17fef000)
#	libpcre.so.3 => /lib/x86_64-linux-gnu/libpcre.so.3 (0x00007fba17d7d000)
#	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fba17b5e000)
#	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fba177c0000)
#	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fba175bc000)
#	/lib64/ld-linux-x86-64.so.2 (0x00007fba195a5000)

FROM ubuntu:18.04
COPY --from=wireshark /usr/local/bin/dumpcap /usr/local/bin/dumpcap
ENV LANG en_CA.UTF-8
ENV LC_ALL en_CA.UTF-8

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        locales util-linux python3 hping3 fping oping \
        inetutils-ping iproute2 curl tcpdump libpcap0.8 libglib2.0-0 libnl-3-200 libnl-genl-3-200 libpcre3 zlib1g libcap2 gdb \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_CA.UTF-8

WORKDIR /root
