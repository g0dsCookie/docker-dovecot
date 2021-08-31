ARG MAJOR
ARG MINOR
ARG PATCH
ARG MAINTENANCE=""

FROM g0dscookie/dovecot:${MAJOR}.${MINOR}.${PATCH}${MAINTENANCE}

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${MAJOR}.${MINOR}.${PATCH}${MAINTENANCE}" \
      sieve_version="${SIEVE}" \
      description="Dovecot is an open source IMAP and POP3 email server for Linux/UNIX-like systems, written with security primarily in mind."

RUN set -eu \
 && apt-get update -qq \
 && apt-get install -qqy rspamd python3 python3-pip \
 && apt-get autoremove -qqy \
 && apt-get clean -qqy
