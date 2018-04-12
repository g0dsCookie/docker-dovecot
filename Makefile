MOPTS			?= -j1
CFLAGS			?= -O2
CPPFLAGS		?= -O2

USERNAME		?= g0dscookie
SERVICE			?= dovecot
TAG				= $(USERNAME)/$(SERVICE)

.PHONY: build
build:
	MAKEOPTS="$(MOPTS)" CFLAGS="$(CFLAGS)" CPPFLAGS="$(CPPFLAGS)" ./build.py --debug --version all

.PHONY: push
push:
	docker push $(TAG)