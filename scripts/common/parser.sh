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

function getVanillaVic3HubName() {
    local HUB_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local HUB_NAME=""
    local CWD="$(pwd)"

    cd "${LOCALISATIONS_DIR}"
    HUB_NAME=$(find . -name "*hub_names_l_english.yml" | xargs cat | \
                grep "^\s*HUB_NAME_${HUB_ID}:" | \
                sed 's/^\s*HUB_NAME_'"${HUB_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g' | \
                head -n 1)
    cd "${CWD}"

    if [ -z "${HUB_NAME}" ] && [ "${LOCALISATIONS_DIR}" != "${Vic3_LOCALISATIONS_DIR}" ]; then
        HUB_NAME=$(cat "${Vic3_LOCALISATIONS_DIR}/hub_names_l_english.yml" | \
                    grep "^\s*HUB_NAME_${HUB_ID}:" | \
                    sed 's/^\s*HUB_NAME_'"${HUB_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g' | \
                head -n 1)
    fi

    echo "${HUB_NAME}"
}