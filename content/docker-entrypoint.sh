#!/usr/bin/env sh

declare -A binaries=(
    ["python2"]="em"
    ["python3"]="em"
    ["perl"]="em"
    ["rspamd"]="em"
    ["rspamadm"]="em"
    ["rspamc"]="em"
)

for key in ${!binaries[@]}; do
    local binary="$(which ${key})" || { echo "${key} not found."; continue; }
    setfattr -n user.pax.flags -v ${binaries[${key}]} "${binary}"
    echo "Updated user.pax.flags on ${binary} to ${binaries[${key}]}"
done

exec $@