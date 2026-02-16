ARG PLATFORM=linux/amd64
# linux/arm64/v8

FROM --platform=${PLATFORM} debian:bookworm-slim AS unbound-builder
ARG UNBOUND_VERSION=1.24.2

RUN apt-get update && apt-get install --yes \
    bison \
    build-essential \
    flex \
    libevent-dev \
    libexpat1-dev \
    libfstrm-dev \
    libhiredis-dev \
    libprotobuf-c-dev \
    libsodium-dev \
    libssl-dev \
    protobuf-c-compiler \
    wget

WORKDIR /src
RUN wget -O unbound.tar.gz https://github.com/NLnetLabs/unbound/archive/refs/tags/release-${UNBOUND_VERSION}.tar.gz \
 && tar -xvf unbound.tar.gz --strip-components=1 \
 && ./configure --prefix=/usr/local --with-libevent --with-pthreads --enable-subnet \
 && make \
 && make install DESTDIR=/install

WORKDIR /install


FROM --platform=${PLATFORM} golang:1-bookworm AS adguard-builder
ARG ADGUARD_VERSION=0.107.71

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get update && apt-get install --yes build-essential nodejs

WORKDIR /src
RUN git clone --depth 1 --branch v${ADGUARD_VERSION} https://github.com/AdguardTeam/AdGuardHome.git .
RUN make VERSION=v${ADGUARD_VERSION}
RUN mkdir -p /install/opt/adguardhome/conf /install/opt/adguardhome/work \
 && mv ./AdGuardHome /install/opt/adguardhome/ \
 && chown -R nobody: /install

WORKDIR /install


FROM --platform=${PLATFORM} debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libssl3 \
    libexpat1 \
    libevent-2.1-7 \
    libprotobuf-c1 \
    libfstrm0 \
    libsodium23 \
    libhiredis0.14 \
    ca-certificates \
 && apt-get autoremove -y && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/*

COPY --from=unbound-builder /install/usr/local /usr/local
COPY unbound.conf /usr/local/etc/unbound/unbound.conf
COPY --from=adguard-builder /install/opt/adguardhome /opt/adguardhome
COPY ./conf/AdGuardHome.yaml /opt/adguardhome/conf/AdGuardHome.yaml
COPY --chmod=0755 entrypoint.sh /entrypoint.sh
RUN useradd -r -s /bin/false dns_service \
 && chown -R dns_service:dns_service /usr/local/etc/unbound \
 && chown -R dns_service:dns_service /opt/adguardhome

EXPOSE 53/tcp 53/udp \
        67/udp \
        68/udp \
        80/tcp \
        443/tcp 443/udp \
        853/tcp 853/udp \
        3000/tcp 3000/udp \
        5443/tcp 5443/udp \
        6060/tcp

USER dns_service

WORKDIR /opt/adguardhome/work
ENTRYPOINT ["/entrypoint.sh"]
