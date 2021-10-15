ARG DOVECOT_VERSION
ARG SIEVE_VERSION
FROM g0dscookie/dovecot:${DOVECOT_VERSION}

ARG DOVECOT_VERSION
ARG SIEVE_VERSION

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${DOVECOT_VERSION}" \
      sieve_version="${SIEVE_VERSION}" \
      description="Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like systems, written with security primarily in mind."

RUN set -eu \
 && apt-get update -qq \
 && apt-get install -qqy rspamd python3 python3-pip \
 && apt-get autoremove -qqy \
 && apt-get clean -qqy
