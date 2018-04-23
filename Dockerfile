FROM alpine:3.7

COPY content/ /

RUN apk add --no-cache --virtual .dovecot-deps \
        curl \
        libressl \
        zlib \
        bzip2 \
        libcap \
        mariadb-client-libs \
        postgresql \
        expat \
        sqlite-libs \
        krb5 \
        openldap \
        clucene \
        lz4 \
        xz \
        icu \
 && for i in dovenull dovecot; do addgroup -S $i && adduser -h /dev/null -s /sbin/nologin -S -g "" -G $i $i; done \
 && addgroup -S vmail \
 && adduser -h /data -s /sbin/nologin -S -g "" -G vmail vmail \
 && mkdir /certificates /sieve-pipe /sieve-filter /conf

ARG DOVECOT_MAJOR
ARG DOVECOT_MINOR
ARG DOVECOT_PATCH
ARG SIEVE_VERSION

ARG MAKEOPTS="-j1"
ARG CFLAGS="-O2"
ARG CPPFLAGS="-O2"

RUN apk add --no-cache --virtual .build-deps \
        gcc g++ \
        libc-dev rpcgen \
        make \
        tar \
        gzip \
        wget \
        linux-headers \
        curl-dev \
        libressl-dev \
        zlib-dev \
        bzip2-dev \
        libcap-dev \
        mariadb-dev \
        postgresql-dev \
        expat-dev \
        sqlite-dev \
        krb5-dev \
        openldap-dev \
        clucene-dev \
        lz4-dev \
        xz-dev \
        icu-dev \
 && BDIR="$(mktemp -d)" \
 && cd "${BDIR}" \
 && wget -qO - "https://dovecot.org/releases/${DOVECOT_MAJOR}.${DOVECOT_MINOR}/dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}.tar.gz" \
        | tar -xzf - \
 && wget -qO - "https://pigeonhole.dovecot.org/releases/${DOVECOT_MAJOR}.${DOVECOT_MINOR}/dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_VERSION}.tar.gz" \
        | tar -xzf - \
 && cd "dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}" \
 && ./configure --prefix="/" --exec-prefix="/usr" --includedir="/usr/include" --datarootdir="/usr/share" \
        --with-statedir="/var/lib/dovecot" --with-rundir="/run/dovecot" --with-moduledir="/usr/lib/dovecot" \
        --disable-rpath --with-bzlib --with-libcap --with-gssapi --with-ldap --with-sql --with-mysql \
        --with-pgsql --with-sqlite --with-solr --with-ssl=openssl --with-zlib --without-stemmer \
        --with-lucene --with-icu --with-lz4 --with-lzma \
        CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" \
 && make ${MAKEOPTS} \
 && make install \
 && cd "../dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_VERSION}" \
 && ./configure --prefix="/" --exec-prefix="/usr" --includedir="/usr/include" --datarootdir="/usr/share" \
            --with-dovecot="../dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}" \
            --enable-shared  --with-managesieve ${SIEVE_CONFIG} CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" \
 && make ${MAKEOPTS} \
 && make install \
 && cd && rm -r "${BDIR}" && apk del .build-deps

ARG JUMBO="False"

RUN [ "${JUMBO}" == "True" ] || exit 0 \
 && apk add --no-cache --virtual .jumbo \
        rspamd \
        python2 py2-pip \
        python3 \
        perl perl-utils \
 && (echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}" \
      description="Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like systems, written with security primarily in mind."

EXPOSE 110 143 993 995 4190

VOLUME [ "/data", "/certificates", "/conf", "/sieve-pipe", "/sieve-filter" ]

ENTRYPOINT [ "/docker-entrypoint.sh", "/usr/sbin/dovecot", "-c", "/conf/dovecot.conf", "-F" ]