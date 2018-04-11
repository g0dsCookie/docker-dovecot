#!/usr/bin/env bash

set -Eeuo pipefail

declare -A VERSIONS=(
    ["2.2.35"]="0.4.23"
    ["2.3.1"]="0.5.1"
)

function build_version() {
    local dmajor dminor dpatch smajor sminor spatch
    IFS='.' read dmajor dminor dpatch smajor sminor spatch <<<$(echo "$1.$2")
    make build \
        DOVECOT_MAJOR=${dmajor} \
        DOVECOT_MINOR=${dminor} \
        DOVECOT_PATCH=${dpatch} \
        SIEVE_MAJOR=${smajor} \
        SIEVE_MINOR=${sminor} \
        SIEVE_PATCH=${spatch} \
        MOPTS="${MAKEOPTS:-"-j1"}" \
        CFLAGS="${CFLAGS:-"-O2"}" \
        CPPFLAGS="${CPPFLAGS:-"-O2"}"
    unset dmajor dminor dpatch smajor sminor spatch
}

if [[ "${1:-unset}" != "unset" ]]; then
    build_version $1 ${VERSIONS[$1]} || { echo "Could not build dovecot-$1"; exit 2; }
    exit 0
fi

lastver=""
for ver in ${!VERSIONS[@]}; do
    build_version ${ver} ${VERSIONS[${ver}]} || { echo "Could not build dovecot-${ver}"; exit 2; }
    lastver="${ver}"
done
docker tag g0dscookie/dovecot:${lastver} g0dscookie/dovecot:latest