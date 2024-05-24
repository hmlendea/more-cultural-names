#!/bin/bash
source "scripts/common/paths.sh"

function getVanillaIrLocationName() {
    local VANILLA_LOCALISATION_FILE="${1}"
    local PROVINCE_ID="${2}"

    cat "${VANILLA_LOCALISATION_FILE}" | \
        grep "^\s*PROV${PROVINCE_ID}:" | \
        tail -n 1 | \
        sed 's/^[^"]*"\([^"]*\).*$/\1/g'
}
