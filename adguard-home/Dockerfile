FROM debian:bookworm-slim AS builder
ARG UNBOUND_VERSION=1.24.2

RUN apt-get update && apt-get install -y \
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
    wget \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN wget -O unbound.tar.gz https://github.com/NLnetLabs/unbound/archive/refs/tags/release-${UNBOUND_VERSION}.tar.gz \
 && tar -xvf unbound.tar.gz --strip-components=1 \
 && ./configure \
        --prefix=/usr/local \
        --with-libevent \
        --with-pthreads \
        --enable-subnet \
        --enable-dnstap \
        --enable-dnscrypt \
        --enable-cachedb \
 && make \
 && make install DESTDIR=/install \
 && sed -i 's/^\s*#\s*use-syslog:\s*yes/use-syslog: no/' /install/usr/local/etc/unbound/unbound.conf \
 && sed -i 's/^\s*#\s*chroot:.*/chroot: ""/' /install/usr/local/etc/unbound/unbound.conf

FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libssl3 \
    libexpat1 \
    libevent-2.1-7 \
    libprotobuf-c1 \
    libfstrm0 \
    libsodium23 \
    libhiredis0.14 \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /install/usr/local /usr/local

RUN useradd -r -s /bin/false unbound \
 && chown -R unbound:unbound /usr/local/etc/unbound

EXPOSE 53/tcp 53/udp

USER unbound

ENTRYPOINT ["/usr/local/sbin/unbound"]
CMD ["-d", "-v", "-c", "/usr/local/etc/unbound/unbound.conf"]
