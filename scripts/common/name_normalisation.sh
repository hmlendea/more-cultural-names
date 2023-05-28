#!/bin/bash

function nameToLocationId() {
    local NAME="${1}"
    local LOCATION_ID=""

    LOCATION_ID=$(echo "${NAME}" | sed \
            -e 's/æ/ae/g' \
            -e 's/\([ČčŠšŽž]\)/\1h/g' \
            -e 's/[Ǧǧ]/j/g' | \
        iconv -f utf8 -t ascii//TRANSLIT | \
        tr '[:upper:]' '[:lower:]')

    LOCATION_ID=$(echo "${LOCATION_ID}" | sed \
            -e 's/ /_/g' \
            -e 's/'"\'"'/-/g' \
            -e 's/^-*//g' \
            -e 's/-*$//g' \
            -e 's/-\+/-/g' \
            \
            -e 's/central/centre/g' \
            -e 's/\(north\|west\|south\|east\)ern/\1/g' \
            \
            -e 's/borealis/north/g' \
            -e 's/occidentalis/west/g' \
            -e 's/australis/south/g' \
            -e 's/orientalis/east/g')

    for I in 1 .. 2; do
        LOCATION_ID=$(echo "${LOCATION_ID}" | sed \
            -e 's/^\(north\|west\|south\|east\)_\(.*\)$/\2_\1/g' \
            -e 's/^\(lower\|upper\|inferior\|superior\)_\(.*\)$/\2_\1/g' \
            -e 's/^\(minor\|maior\|lesser\|greater\)_\(.*\)$/\2_\1/g' \
            -e 's/^\(centre\)_\(.*\)$/\2_\1/g')
    done

    echo "${LOCATION_ID}"
}

function locationIdToSearcheableId() {
    local LOCATION_ID="${1}"

    echo "${LOCATION_ID}" | sed \
        -e 's/^[ekdcb]_//g' \
        -e 's/[_-]//g' \
        -e 's/\(baron\|castle\|church\|city\|fort\|temple\|town\)//g'
}
