MAJOR	?=
MINOR	?=
PATCH	?=
MAINT	?=

TAG	= g0dscookie/dovecot
TAGLIST = -t ${TAG}:${MAJOR}-bloat -t ${TAG}:${MAJOR}.${MINOR}-bloat -t ${TAG}:${MAJOR}.${MINOR}.${PATCH}-bloat
BUILDARGS = --build-arg MAJOR=${MAJOR} --build-arg MINOR=${MINOR} --build-arg PATCH=${PATCH}

ifneq (${MAINT},)
	MAINTENANCE := .${MAINT}
	TAGLIST += -t ${TAG}:${MAJOR}.${MINOR}.${PATCH}${MAINTENANCE}-bloat
	BUILDARGS += --build-arg MAINTENANCE=${MAINTENANCE}
endif

PLATFORM_FLAGS	?= --platform linux/amd64 --platform linux/arm64
PUSH ?= --push

build:
	docker buildx build ${PUSH} ${PLATFORM_FLAGS} ${BUILDARGS} ${TAGLIST} .

latest: TAGLIST := -t ${TAG}:latest-bloat ${TAGLIST}
latest: build
.PHONY: build latest

amd64: PLATFORM_FLAGS := --platform linux/amd64
amd64: build
amd64-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
amd64-latest: amd64
.PHONY: amd64 amd64-latest

arm64: PLATFORM_FLAGS := --platform linux/arm64
arm64: build
arm64-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
arm64-latest: arm64
.PHONY: arm64 arm64-latest
