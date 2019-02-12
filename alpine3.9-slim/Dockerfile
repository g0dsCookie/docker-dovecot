FROM alpine:3.9

ARG DOVECOT_MAJOR
ARG DOVECOT_MINOR
ARG DOVECOT_PATCH
ARG DOVECOT_MAINTENANCE=""
ARG SIEVE_VERSION

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}${DOVECOT_MAINTENANCE}" \
      sieve_version="${SIEVE_VERSION}" \
      description="Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like systems, written with security primarily in mind."

RUN set -eu \
 && cecho() { echo "\033[1;32m$1\033[0m"; } \
 && cecho "##### INSTALLING DOVECOT DEPENDENCIES #####" \
 && apk add --no-cache --virtual .dovecot-deps \
       curl openssl zlib bzip2 libcap mariadb-connector-c \
       postgresql expat sqlite-libs krb5 openldap clucene \
       lz4 xz icu rspamd-client \
 && apk add --no-cache --virtual .dovecot-bdeps \
       gcc g++ libc-dev rpcgen make tar gzip \
       linux-headers curl-dev openssl-dev zlib-dev \
       bzip2-dev libcap-dev mariadb-connector-c-dev postgresql-dev \
       expat-dev sqlite-dev krb5-dev openldap-dev \
       clucene-dev lz4-dev xz-dev icu-dev \
 && MAKEOPTS="-j$(nproc)" \
 && BDIR="$(mktemp -d)" && cd "${BDIR}" \
 && DOVECOT_VERSION="${DOVECOT_MAJOR}.${DOVECOT_MINOR}.${DOVECOT_PATCH}${DOVECOT_MAINTENANCE}" \
 && cecho "##### INSTALLING DOVECOT ${DOVECOT_VERSION} #####" \
 && curl -sSL -o "dovecot-${DOVECOT_VERSION}.tar.gz" "https://dovecot.org/releases/${DOVECOT_MAJOR}.${DOVECOT_MINOR}/dovecot-${DOVECOT_VERSION}.tar.gz" \
 && tar -xzf "dovecot-${DOVECOT_VERSION}.tar.gz" && cd "dovecot-${DOVECOT_VERSION}"\
 && ./configure --prefix="/" --exec-prefix="/usr" --includedir="/usr/include" --datarootdir="/usr/share" \
       --with-statedir="/var/lib/dovecot" --with-rundir="/run/dovecot" --with-moduledir="/usr/lib/dovecot" \
       --disable-rpath --with-bzlib --with-libcap --with-gssapi --with-ldap --with-sql --with-mysql \
       --with-pgsql --with-sqlite --with-solr --with-ssl=openssl --with-zlib --without-stemmer \
       --with-lucene --with-icu --with-lz4 --with-lzma \
 && make ${MAKEOPTS} && make install && cd .. \
 && cecho "##### INSTALLING DOVECOT SIEVE ${SIEVE_VERSION} #####" \
 && curl -sSL -o "dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_VERSION}.tar.gz" "https://pigeonhole.dovecot.org/releases/${DOVECOT_MAJOR}.${DOVECOT_MINOR}/dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_VERSION}.tar.gz" \
 && tar -xzf "dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_VERSION}.tar.gz" && cd "dovecot-${DOVECOT_MAJOR}.${DOVECOT_MINOR}-pigeonhole-${SIEVE_VERSION}" \
 && ./configure --prefix="/" --exec-prefix="/usr" --includedir="/usr/include" --datarootdir="/usr/share" \
       --with-dovecot="../dovecot-${DOVECOT_VERSION}" \
       --enable-shared  --with-managesieve \
 && make ${MAKEOPTS} && make install && cd \
 && cecho "##### CLEANING BUILD DIR #####" \
 && rm -r "${BDIR}" \
 && cecho "##### REMOVING BUILD DEPENDENCIES #####" \
 && apk del .dovecot-bdeps \
 && cecho "##### CREATING DOVECOT USERS #####" \
 && for i in dovenull dovecot; do addgroup -S ${i} && adduser -h /dev/null -s /sbin/nologin -S -g "" -G ${i} ${i}; done \
 && addgroup -S vmail && adduser -h /data -s /sbin/nologin -S -g "" -G vmail vmail \
 && mkdir /certificates /sieve-pipe /sieve-filter /conf \
 && cecho "##### COPYING EXAMPLE CONFIG #####" \
 && cp -av "/usr/share/doc/dovecot/example-config/." "/conf/"

EXPOSE 110 143 993 995 4190

VOLUME [ "/data", "/certificates", "/conf", "/sieve-pipe", "/sieve-filter" ]

ENTRYPOINT [ "/usr/sbin/dovecot", "-c", "/conf/dovecot.conf", "-F" ]
