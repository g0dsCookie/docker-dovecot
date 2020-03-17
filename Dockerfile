FROM alpine:3.11

ARG MAJOR
ARG MINOR
ARG PATCH
ARG MAINTENANCE=""
ARG SIEVE

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${MAJOR}.${MINOR}.${PATCH}${MAINTENANCE}" \
      sieve_version="${SIEVE}" \
      description="Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like systems, written with security primarily in mind."

RUN set -eu \
 && apk add --no-cache --virtual .dovecot-deps \
 	curl openssl zlib bzip2 libcap mariadb-connector-c \
	postgresql expat sqlite-libs krb5 openldap clucene \
	lz4 xz icu libsodium \
 && for i in dovenull dovecot; do addgroup -S ${i} && adduser -h /dev/null -s /sbin/nologin -S -g "" -G ${i} ${i}; done \
 && addgroup -S vmail && adduser -h /data -s /sbin/nologin -S -g "" -G vmail vmail \
 && mkdir -p /etc/dovecot /data \
 && chown vmail:vmail /data

RUN set -eu \
 && apk add --no-cache --virtual .dovecot-bdeps \
       gcc g++ libc-dev rpcgen make tar gzip \
       linux-headers curl-dev openssl-dev zlib-dev \
       bzip2-dev libcap-dev mariadb-connector-c-dev postgresql-dev \
       expat-dev sqlite-dev krb5-dev openldap-dev \
       clucene-dev lz4-dev xz-dev icu-dev libsodium-dev \
 && MAKEOPTS="-j$(nproc)" \
 && BDIR="$(mktemp -d)" && cd "${BDIR}" \
 && DOVECOT_VERSION="${MAJOR}.${MINOR}.${PATCH}${MAINTENANCE}" \
 && curl -sSL -o "dovecot-${DOVECOT_VERSION}.tar.gz" "https://dovecot.org/releases/${MAJOR}.${MINOR}/dovecot-${DOVECOT_VERSION}.tar.gz" \
 && tar -xzf "dovecot-${DOVECOT_VERSION}.tar.gz" && cd "dovecot-${DOVECOT_VERSION}"\
 && ./configure --prefix="/" --exec-prefix="/usr" --includedir="/usr/include" --datarootdir="/usr/share" \
       --with-statedir="/var/lib/dovecot" --with-rundir="/run/dovecot" --with-moduledir="/usr/lib/dovecot" \
       --disable-rpath --with-bzlib --with-libcap --with-gssapi --with-ldap --with-sql --with-mysql \
       --with-pgsql --with-sqlite --with-solr --with-ssl=openssl --with-zlib --without-stemmer \
       --with-lucene --with-icu --with-lz4 --with-lzma --with-sodium \
 && make ${MAKEOPTS} && make install && cd .. \
 && curl -sSL -o "dovecot-${MAJOR}.${MINOR}-pigeonhole-${SIEVE}.tar.gz" "https://pigeonhole.dovecot.org/releases/${MAJOR}.${MINOR}/dovecot-${MAJOR}.${MINOR}-pigeonhole-${SIEVE}.tar.gz" \
 && tar -xzf "dovecot-${MAJOR}.${MINOR}-pigeonhole-${SIEVE}.tar.gz" && cd "dovecot-${MAJOR}.${MINOR}-pigeonhole-${SIEVE}" \
 && ./configure --prefix="/" --exec-prefix="/usr" --includedir="/usr/include" --datarootdir="/usr/share" \
 	--with-dovecot="../dovecot-${DOVECOT_VERSION}" \
       --enable-shared  --with-managesieve \
 && make ${MAKEOPTS} && make install && cd \
 && rm -r "${BDIR}" \
 && apk del .dovecot-bdeps \
 && cp -av "/usr/share/doc/dovecot/example-config/." "/etc/dovecot/"

EXPOSE 110 143 993 995 4190

VOLUME [ "/data", "/etc/dovecot" ]

ENTRYPOINT [ "/usr/sbin/dovecot", "-c", "/etc/dovecot/dovecot.conf", "-F" ]
