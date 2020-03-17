MAJOR	?= 2
MINOR	?= 3
PATCH	?= 10
MAINT	?=
SIEVE	?= 0.5.10

TAG		= g0dscookie/dovecot
TAGLIST		= -t ${TAG}:${MAJOR} -t ${TAG}:${MAJOR}.${MINOR} -t ${TAG}:${MAJOR}.${MINOR}.${PATCH}
BUILDARGS	= --build-arg MAJOR=${MAJOR} --build-arg MINOR=${MINOR} --build-arg PATCH=${PATCH} --build-arg SIEVE=${SIEVE}

ifneq (${MAINT},)
MAINTENANCE	:= .${MAINT}
TAGLIST		+= -t ${TAG}:${MAJOR}.${MINOR}.${PATCH}${MAINTENANCE}
BUILDARGS	+= --build-arg MAINTENANCE=${MAINTENANCE}
endif

PLATFORM_FLAGS	= --platform linux/amd64 --platform linux/arm64 --platform linux/arm/v6
PUSH		?= --push

build:
	docker buildx build ${PUSH} ${PLATFORM_FLAGS} ${BUILDARGS} ${TAGLIST} .

latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
latest: build

amd64: PLATFORM_FLAGS := --platform linux/amd64
amd64: build
amd64-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
amd64-latest: amd64

arm64: PLATFORM_FLAGS := --platform linux/arm64
arm64: build
arm64-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
arm64-latest: arm64

arm: PLATFORM_FLAGS := --platform linux/arm
arm: build
arm-latest: TAGLIST := -t ${TAG}:latest ${TAGLIST}
arm-latest: arm

.PHONY: build latest amd64 amd64-latest arm arm-latest arm64 arm64-latest
