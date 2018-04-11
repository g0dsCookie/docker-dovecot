FROM alpine:3.7

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>"

ARG DOVECOT_MAJOR
ARG DOVECOT_MINOR
ARG DOVECOT_PATCH
ARG SIEVE_MAJOR
ARG SIEVE_MINOR
ARG SIEVE_PATCH
ARG MAKEOPTS="-j1"
ARG CFLAGS="-O2 -mtune=core2"
ARG CPPFLAGS="-O2 -mtune=core2"

RUN set -eu \
    && apk add --no-cache --virtual .dovecot-deps \
        libressl \
        zlib \
        bzip2 \
        libcap \
        clucene \
        xz \
        lz4 \
        mariadb \
        postgresql \
        expat \
        sqlite \
        icu \
        krb5 \
        openldap \
    && apk add --no-cache --virtual .build-deps \
        gcc g++ \
        libc-dev \
        make \
        curl \
        tar \
        gzip \
        wget \
        linux-headers \
        libressl-dev \
        zlib-dev \
        bzip2-dev \
        libcap-dev \
        clucene-dev \
        xz-dev \
        lz4-dev \
        mariadb-dev \
        postgresql-dev \
        expat-dev \
        sqlite-dev \
        icu-dev \
        krb5-dev \
        openldap-dev \
    && for i in dovenull dovecot; do addgroup -S $i; adduser -h /dev/null -s /sbin/nologin -S -g "" -G $i $i; done \
    && BDIR="$(mktemp -d)" \
    && cd "${BDIR}" \
    && wget -qO - "https://dovecot.org/releases/${DOVECOT_MAJOR}.${DOVECOT_MINOR}/dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}.tar.gz" \
        | tar -xzf - \
    && wget -qO - "https://pigeonhole.dovecot.org/releases/${DOVECOT_MAJOR}.${DOVECOT_MINOR}/dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_MAJOR}.${SIEVE_MINOR}.${SIEVE_PATCH}.tar.gz" \
        | tar -xzf - \
    && cd "dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}" \
    && ./configure --prefix="/" --with-statedir="/var/lib/dovecot" --with-rundir="/run/dovecot" --with-moduledir="/usr/libexec/dovecot" \
        --without-stemmer --disable-rpath --with-icu --with-bzlib --with-libcap --with-gssapi --with-ldap --with-lucene \
        --with-lz4 --with-lzma --with-sql --with-mysql --with-pgsql --with-sqlite --with-solr --with-ssl=openssl --with-zlib \
        CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" \
    && make ${MAKEOPTS} \
    && make install \
    && cd "../dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_MAJOR}.${SIEVE_MINOR}.${SIEVE_PATCH}" \
    && ./configure --prefix="/" --with-dovecot="../dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}" \
            --enable-shared  --with-managesieve CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" \
    && make ${MAKEOPTS} \
    && make install \
    && cd && rm -r "${BDIR}" \
    && apk del .build-deps

EXPOSE 110 143 993 995 4190

ENTRYPOINT [ "/sbin/dovecot", "-c", "/etc/dovecot/dovecot.conf", "-F" ]