#!/usr/bin/env bash

declare -A binaries=(
    ["python2"]="em"
    ["python3"]="em"
    ["perl"]="em"
    ["rspamd"]="em"
    ["rspamadm"]="em"
    ["rspamc"]="em"
)

if [[ -e /.jumbo ]]; then
	for key in ${!binaries[@]}; do
	    binary="$(which ${key})"
	    setfattr -n user.pax.flags -v ${binaries[${key}]} "${binary}"
	    echo "Updated user.pax.flags on ${binary} to ${binaries[${key}]}"
	done
fi

exec $@
