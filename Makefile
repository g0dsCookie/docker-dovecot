MAJOR			?= 2
MINOR			?= 3
PATCH			?= 7
MAINT			?=
SIEVE_VERSION		?= 0.5.7

TAG	= g0dscookie/dovecot
TAGLIST = -t ${TAG}:${MAJOR} -t ${TAG}:${MAJOR}.${MINOR} -t ${TAG}:${MAJOR}.${MINOR}.${PATCH}
BUILDARGS = --build-arg DOVECOT_MAJOR=${MAJOR} --build-arg DOVECOT_MINOR=${MINOR} --build-arg DOVECOT_PATCH=${PATCH} --build-arg SIEVE_VERSION=${SIEVE_VERSION}

ifneq (${MAINT},)
MAINTENANCE := .${MAINT}
TAGLIST += -t ${TAG}:${MAJOR}.${MINOR}.${PATCH}${MAINTENANCE}
BUILDARGS += --build-arg DOVECOT_MAINTENANCE=${MAINTENANCE}
endif

.PHONY: nothing
nothing:
	@echo "No job given."
	@exit 1

.PHONY: all
all: alpine3.9

.PHONY: all-latest
all-latest: alpine3.9-latest

.PHONY: alpine3.9
alpine3.9: pull
	docker build ${BUILDARGS} ${TAGLIST} alpine3.9

.PHONY: alpine3.9-latest
alpine3.9-latest: pull
	docker build ${BUILDARGS} -t ${TAG}:latest ${TAGLIST} alpine3.9

.PHONY: clean
clean:
	docker rmi -f $(shell docker images -aq ${TAG})

.PHONY: push
push:
	docker push $(TAG)

.PHONY: pull
pull:
	docker pull ${TAG}:latest

