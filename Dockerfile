FROM alpine:3.7

##### VERSIONS #####
ARG DOVECOT_MAJOR
ARG DOVECOT_MINOR
ARG DOVECOT_PATCH

ARG SIEVE_MAJOR
ARG SIEVE_MINOR
ARG SIEVE_PATCH
##### VERSIONS #####

##### DEPENDENCIES #####
ARG DOVECOT_DEPS
ARG BUILD_DEPS
##### DEPENDENCIES #####

##### CONFIGURATIONS #####
ARG DOVECOT_CONFIG
ARG SIEVE_CONFIG

ARG MAKEOPTS="-j1"
ARG CFLAGS="-O2"
ARG CPPFLAGS="-O2"
##### CONFIGURATIONS #####

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}" \
      description="Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like systems, written with security primarily in mind."

RUN set -eu \
    && apk add --no-cache --virtual .dovecot-deps ${DOVECOT_DEPS} \
    && apk add --no-cache --virtual .build-deps \
        gcc g++ \
        libc-dev rpcgen \
        make \
        tar \
        gzip \
        wget \
        linux-headers \
        ${BUILD_DEPS} \
    && for i in dovenull dovecot; do addgroup -S $i; adduser -h /dev/null -s /sbin/nologin -S -g "" -G $i $i; done \
    && BDIR="$(mktemp -d)" \
    && cd "${BDIR}" \
    && wget -qO - "https://dovecot.org/releases/${DOVECOT_MAJOR}.${DOVECOT_MINOR}/dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}.tar.gz" \
        | tar -xzf - \
    && wget -qO - "https://pigeonhole.dovecot.org/releases/${DOVECOT_MAJOR}.${DOVECOT_MINOR}/dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_MAJOR}.${SIEVE_MINOR}.${SIEVE_PATCH}.tar.gz" \
        | tar -xzf - \
    && cd "dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}" \
    && ./configure --prefix="/" --exec-prefix="/usr" --includedir="/usr/include" --datarootdir="/usr/share" \
        --with-statedir="/var/lib/dovecot" --with-rundir="/run/dovecot" --with-moduledir="/usr/lib/dovecot" \
        ${DOVECOT_CONFIG} CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" \
    && make ${MAKEOPTS} \
    && make install \
    && cd "../dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_MAJOR}.${SIEVE_MINOR}.${SIEVE_PATCH}" \
    && ./configure --prefix="/" --exec-prefix="/usr" --includedir="/usr/include" --datarootdir="/usr/share" \
            --with-dovecot="../dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}" \
            --enable-shared  --with-managesieve ${SIEVE_CONFIG} CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" \
    && make ${MAKEOPTS} \
    && make install \
    && cd && rm -r "${BDIR}" "/etc/dovecot" \
    && apk del .build-deps \
    && mkdir /certificates /sieve-pipe /sieve-filter /data /conf

EXPOSE 110 143 993 995 4190

VOLUME [ "/data", "/certificates", "/conf", "/sieve-pipe", "/sieve-filter" ]

ENTRYPOINT [ "/usr/sbin/dovecot", "-c", "/conf/dovecot.conf", "-F" ]