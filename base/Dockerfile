ARG DEBIAN_VERSION=11
FROM debian:${DEBIAN_VERSION}

ARG DOVECOT_VERSION
ARG SIEVE_VERSION

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${DOVECOT_VERSION}" \
      sieve_version="${SIEVE_VERSION}" \
      description="Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like systems, written with security primarily in mind."

RUN set -eu \
 && DOVECOT_VERSION="$(echo ${DOVECOT_VERSION} | sed 's/^v//')" \
 && echo "${DOVECOT_VERSION}" >ver \
 && IFS='.' read MAJOR MINOR PATCH <ver && rm -f ver \
 && cecho() { echo "\033[1;32m$1\033[0m"; } \
 && cecho "### PREPARE ENVIRONMENT ###" \
 && TMP="$(mktemp -d)" && PV="${DOVECOT_VERSION}" && S="${TMP}/dovecot-${PV}" \
 && for i in dovenull dovecot; do useradd -d /dev/null -s /sbin/nologin -M -r $i; done \
 && useradd -d /data -M -s /sbin/nologin vmail \
 && mkdir /data && chown vmail:vmail /data && chmod 0700 /data \
 && mkdir /var/lib/dovecot /run/dovecot && chown dovecot:dovecot /var/lib/dovecot /run/dovecot && chmod 0700 /var/lib/dovecot /run/dovecot \
 && cecho "### INSTALLING DEPENDENCIES ###" \
 && apt-get update -qq \
 && apt-get install -qqy \
        build-essential curl gnupg pkg-config \
        libssl-dev libcurl4-openssl-dev zlib1g-dev libbz2-dev \
        libcap-dev libmariadb-dev libmariadb-dev-compat \
        libpq-dev libexpat1-dev libstemmer-dev \
        libsqlite3-dev libkrb5-dev libldap2-dev liblz4-dev \
        libclucene-dev liblzma-dev libicu-dev libsodium-dev \
 && apt-get install -qqy \
        libcurl4 zlib1g libbz2-1.0 libmariadb3 libpq5 libexpat1 libcap2 \
        libsqlite3-0 libkrb5-3 libldap-2.4-2 liblz4-1 libclucene-core1v5 \
        liblzma5 libicu67 libsodium23 libstemmer0d \
 && cecho "### DOWNLOADING DOVECOT ###" \
 && cd "${TMP}" \
 && curl -sSL --output "dovecot-${PV}.tar.gz" "https://dovecot.org/releases/${MAJOR}.${MINOR}/dovecot-${PV}.tar.gz" \
 && tar -xf "dovecot-${PV}.tar.gz" \
 && cecho "### DOWNLOADING SIEVE ###" \
 && curl -sSL -o "dovecot-${MAJOR}.${MINOR}-pigeonhole-${SIEVE_VERSION}.tar.gz" "https://pigeonhole.dovecot.org/releases/${MAJOR}.${MINOR}/dovecot-${MAJOR}.${MINOR}-pigeonhole-${SIEVE_VERSION}.tar.gz" \
 && tar -xzf "dovecot-${MAJOR}.${MINOR}-pigeonhole-${SIEVE_VERSION}.tar.gz" \
 && cecho "### BUILDING DOVECOT ###" \
 && cd "dovecot-${PV}" \
 && ./configure --disable-static \
      --prefix=/usr --sysconfdir=/etc --with-statedir=/var/lib/dovecot --with-rundir=/run/dovecot --with-moduledir=/usr/lib/dovecot \
      --disable-rpath --with-bzlib --with-libcap --with-gssapi --with-ldap --with-sql --with-mysql \
      --with-pgsql --with-sqlite --with-solr --with-ssl=openssl --with-zlib --with-stemmer \
      --with-lucene --with-icu --with-lz4 --with-lzma --with-sodium --without-pam \
 && make -j$(nproc) \
 && make install \
 && cp -Rv /usr/share/doc/dovecot/example-config/* /etc/dovecot \
 && sed -i \
       -e 's:^\(ssl_key\):#\1:' \
       -e 's:^\(ssl_cert\):#\1:' \
       /etc/dovecot/conf.d/10-ssl.conf \
 && sed -i \
       -e 's:^#\(log_path\).*:\1 = /dev/stdout:' \
       /etc/dovecot/conf.d/10-logging.conf \
 && cd .. \
 && cecho "### BUILDING SIEVE ###" \
 && cd "dovecot-${MAJOR}.${MINOR}-pigeonhole-${SIEVE_VERSION}" \
 && ./configure --disable-static --prefix=/usr --sysconfdir=/etc --with-moduledir=/usr/lib/dovecot \
 	--with-dovecot="../dovecot-${PV}" --enable-shared  --with-managesieve \
 && make -j$(nproc) \
 && make install \
 && cd .. \
 && cecho "### CLEANUP ###" \
 && cd && rm -rf "${TMP}" \
 && apt-get remove -qqy \
        build-essential curl gnupg pkg-config \
        libssl-dev libcurl4-openssl-dev zlib1g-dev libbz2-dev \
        libcap-dev libmariadbclient-dev libmariadb-dev-compat \
        libpq-dev libexpat1-dev libstemmer-dev \
        libsqlite3-dev libkrb5-dev libldap2-dev liblz4-dev \
        libclucene-dev liblzma-dev libicu-dev libsodium-dev \
 && apt-get autoremove -qqy \
 && apt-get clean -qqy

EXPOSE 110 143 993 995 4190
VOLUME [ "/data", "/etc/dovecot" ]
WORKDIR /var/lib/dovecot
ENTRYPOINT [ "/usr/sbin/dovecot", "-c", "/etc/dovecot/dovecot.conf", "-F" ]
