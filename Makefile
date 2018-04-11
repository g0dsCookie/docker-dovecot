DOVECOT_MAJOR	?=
DOVECOT_MINOR	?=
DOVECOT_PATCH	?=
SIEVE_MAJOR		?=
SIEVE_MINOR		?=
SIEVE_PATCH		?=
MOPTS			?= -j1
CFLAGS			?= -O2
CPPFLAGS		?= -O2

USERNAME		?= g0dscookie
SERVICE			?= dovecot
TAG				= $(USERNAME)/$(SERVICE)

build:
	docker build \
		--build-arg DOVECOT_MAJOR=$(DOVECOT_MAJOR) \
		--build-arg DOVECOT_MINOR=$(DOVECOT_MINOR) \
		--build-arg DOVECOT_PATCH=$(DOVECOT_PATCH) \
		--build-arg SIEVE_MAJOR=$(SIEVE_MAJOR) \
		--build-arg SIEVE_MINOR=$(SIEVE_MINOR) \
		--build-arg SIEVE_PATCH=$(SIEVE_PATCH) \
		--build-arg MAKEOPTS="$(MOPTS)" \
		--build-arg CFLAGS="$(CFLAGS)" \
		--build-arg CPPFLAGS="$(CPPFLAGS)" \
		-t $(TAG):$(DOVECOT_MAJOR) \
		-t $(TAG):$(DOVECOT_MAJOR).$(DOVECOT_MINOR) \
		-t $(TAG):$(DOVECOT_MAJOR).$(DOVECOT_MINOR).$(DOVECOT_PATCH) \
		.

push:
	docker push $(TAG)