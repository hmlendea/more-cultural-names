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

declare -A VIC3_VANILLA_HUB_NAMES=()

function loadVanillaVic3HubNames() {
    local HUB_ID
    local HUB_NAME
    local CWD="$(pwd)"

    [ ${#VIC3_VANILLA_HUB_NAMES[@]} -gt 0 ] && return
    [ ! -d "${Vic3_LOCALISATIONS_DIR}" ] && return

    cd "${Vic3_LOCALISATIONS_DIR}"
    while IFS=$'\t' read -r HUB_ID HUB_NAME; do
        [ -n "${VIC3_VANILLA_HUB_NAMES[${HUB_ID}]+x}" ] && continue
        VIC3_VANILLA_HUB_NAMES["${HUB_ID}"]="${HUB_NAME}"
    done < <(find . -name "*hub_names_l_english.yml" -exec cat {} + | \
                grep -P '^\s*HUB_NAME_[^:]*:[0-9]*\s*"' | \
                sed 's/^\s*HUB_NAME_\([^:]*\):[0-9]*\s*"\([^"]*\)".*/\1\t\2/')
    cd "${CWD}"
}

loadVanillaVic3HubNames

function getVanillaVic3HubName() {
    local HUB_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local HUB_NAME=""
    local CWD="$(pwd)"

    if [ "${LOCALISATIONS_DIR}" = "${Vic3_LOCALISATIONS_DIR}" ]; then
        loadVanillaVic3HubNames
        [ -n "${HUB_ID}" ] && HUB_NAME="${VIC3_VANILLA_HUB_NAMES[${HUB_ID}]:-}"
        echo "${HUB_NAME}"
        return
    fi

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