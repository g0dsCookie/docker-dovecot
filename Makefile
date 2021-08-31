MAJOR	?= 2
MINOR	?= 3
PATCH	?= 16
MAINT	?=
SIEVE	?= 0.5.16
PLATFORM_FLAGS	?= --platform linux/amd64 --platform linux/arm64
PUSH    ?= --push

export

latest: latest-base latest-bloat

build-base:
	$(MAKE) -C base build
latest-base:
	$(MAKE) -C base latest
amd64-base: PLATFORM_FLAGS := --platform linux/amd64
amd64-base: build-base
amd64-latest-base: PLATFORM_FLAGS := --platform linux/amd64
amd64-latest-base: latest-base
arm64-base: PLATFORM_FLAGS := --platform linux/arm64
arm64-base: build-base
arm64-latest-base: PLATFORM_FLAGS := --platform linux/arm64
arm64-latest-base: latest-base

build-bloat:
	$(MAKE) -C bloat build
latest-bloat:
	$(MAKE) -C bloat latest
amd64-bloat: PLATFORM_FLAGS := --platform linux/amd64
amd64-bloat: build-bloat
amd64-latest-bloat: PLATFORM_FLAGS := --platform linux/amd64
amd64-latest-bloat: latest-bloat
arm64-bloat: PLATFORM_FLAGS := --platform linux/arm64
arm64-bloat: build-bloat
arm64-latest-bloat: PLATFORM_FLAGS := --platform linux/arm64
arm64-latest-bloat: latest-bloat

amd64: amd64-base amd64-bloat
amd64-latest: amd64-latest-base amd64-latest-bloat
arm64: arm64-base arm64-bloat
arm64-latest: arm64-latest-base arm64-latest-bloat
