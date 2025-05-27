#!/bin/bash
source "scripts/common/paths.sh"
source "${SCRIPTS_COMMON_GAMES_DIR}/utils.sh"
source "${SCRIPTS_COMMON_GAMES_DIR}/hoi4.sh"

function update-vanilla-file() {
    local SOURCE_FILE="${1}"
    local TARGET_FILE="${2}"
    local SOURCE_URL="${3}"

    if compgen -G "${SOURCE_FILE}" > /dev/null; then
        cat "${SOURCE_FILE}" > "${TARGET_FILE}"
    elif [ -n "${SOURCE_URL}" ]; then
        wget -qc --no-check-certificate "${SOURCE_URL}" -O "${TARGET_FILE}" 2>/dev/null
    fi

    if [ -f "${TARGET_FILE}" ]; then
        chmod 755 "${TARGET_FILE}"
        chown "${USER}:${USER}" "${TARGET_FILE}"
        sed -i 's/\r$//' "${TARGET_FILE}"
    fi
}

function update-vanilla-files() {
    local TARGET_FILE="${1}" && shift

    cat "${@}" > "${TARGET_FILE}"

    chmod 755 "${TARGET_FILE}"
    chown "${USER}:${USER}" "${TARGET_FILE}"
    sed -i 's/\r$//' "${TARGET_FILE}"
    sed -i 's/﻿/\n/g' "${TARGET_FILE}"
}

function update_hoi4_parentage_file() {
    local GAME_ID="${1}"
    local TARGET_FILE="${2}"
    local STATES_DIR=$(get_variable "${GAME_ID}_STATES_DIR")
    local LOCALISATIONS_DIR=$(get_variable "${GAME_ID}_LOCALISATIONS_DIR")

    if ! find "${LOCALISATIONS_DIR}" -name '*.yml' -exec cat {} + 2>/dev/null | grep -q 'VICTORY_POINTS'; then
        LOCALISATIONS_DIR="${HOI4_LOCALISATIONS_DIR}"
    fi

    if [ -f "${TARGET_FILE}" ]; then
        rm "${TARGET_FILE}"
        touch "${TARGET_FILE}"
    fi

    LOCALISED_CITY_IDS=$(find "${LOCALISATIONS_DIR}" -name '*.yml' -exec cat {} + | \
                            grep "^\s*VICTORY_POINTS_[1-9][0-9]*:" | \
                            sed 's/^\s*VICTORY_POINTS_\([1-9][0-9]*\)\s*:.*/\1/g')

    for FILE in "${STATES_DIR}"/*.txt ; do
        local STATE_ID=$(basename "${FILE}" | sed 's/^\([0-9]*\)\s*-\s*.*/\1/g')
        echo "${STATE_ID}" | grep -q '[^0-9]' && continue

        CITY_IDS=$(cat "${FILE}" | \
            sed 's/\r//g' | \
            tr '\n' ' ' | \
            sed 's/\s\s*/ /g' | \
            sed 's/.*provinces\s*=\s*{\([^}]*\).*/\1/g' | \
            sed 's/\(^\s*\|\s*$\)//g')

        [[ -z "${CITY_IDS// }" ]] && continue

        for CITY_ID in ${CITY_IDS}; do
            echo "${CITY_ID}" | grep -q '[^0-9]' && continue
            ! echo "${LOCALISED_CITY_IDS}" | grep -q "\b${CITY_ID}\b" && continue

            echo "${CITY_ID}=${STATE_ID}" >> "${TARGET_FILE}"
        done
    done
}

function update-vic3-countries() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local COUNTRIES_DIR="${3}"
    local TARGET_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_countries.txt"

    if [ -f "${TARGET_FILE}" ]; then
        rm "${TARGET_FILE}"
        touch "${TARGET_FILE}"
    fi

    local COUNTRY_IDS=$(grep "^[A-Z][A-Z][A-Z]\s*=\s*{" "${COUNTRIES_DIR}"/*.txt | \
                    sed 's/^[^:]*://g' |
                    sed 's/^\([A-Z][A-Z][A-Z]\).*/\1/g' | \
                    sort | uniq)
    local COUNTRY_NAME=""

    for COUNTRY_ID in ${COUNTRY_IDS} ; do
        COUNTRY_NAME=$(grep "^ ${COUNTRY_ID}:[0-9]\s*" "${LOCALISATIONS_DIR}"/*.yml | \
                                sed 's/^[^\"]*\"\([^\"]*\)\".*/\1/g' | \
                                tail -n 1)
        echo "${COUNTRY_ID}=${COUNTRY_NAME}" >> "${TARGET_FILE}"
    done
}

function update-vic3-states() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local STATES_DIR="${3}"
    local TARGET_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_states.txt"

    if [ -f "${TARGET_FILE}" ]; then
        rm "${TARGET_FILE}"
        touch "${TARGET_FILE}"
    fi

    local STATE_IDS=$(grep "^\s*s:[^ ]*\s*=\s*{" "${STATES_DIR}"/*.txt | \
                    sed 's/^\s*s:\([^ ]*\).*/\1/g' |
                    sort | uniq)
    local STATE_NAME=""

    for STATE_ID in ${STATE_IDS} ; do
        STATE_NAME=$(grep "^ ${STATE_ID}:[0-9]\s*" "${LOCALISATIONS_DIR}/map"/*.yml | \
                                sed 's/^[^\"]*\"\([^\"]*\)\".*/\1/g' | \
                                tail -n 1)
        echo "${STATE_ID}=${STATE_NAME}" >> "${TARGET_FILE}"
    done
}

function update-vic3-hubs() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local TARGET_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_hubs.txt"

    if [ -f "${TARGET_FILE}" ]; then
        rm "${TARGET_FILE}"
        touch "${TARGET_FILE}"
    fi

    local HUB_NAME=""
    local HUB_IDS=$(grep "^\s*HUB_NAME_" "${LOCALISATIONS_DIR}"/*.yml | \
                    sed 's/^[^:]*:\s*HUB_NAME_\([^:]*\).*/\1/g' |
                    sort | uniq)

    for HUB_ID in ${HUB_IDS} ; do
        HUB_NAME=$(grep "^ HUB_NAME_${HUB_ID}:[0-9]\s*" "${LOCALISATIONS_DIR}"/*.yml | \
                    sed 's/^[^\"]*\"\([^\"]*\)\".*/\1/g' | \
                    tail -n 1)
        echo "${HUB_ID}=${HUB_NAME}" >> "${TARGET_FILE}"
    done
}

function update-vic3-files() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local COUNTRIES_DIR="${3}"
    local STATES_DIR="${4}"

    #update-vic3-countries "${GAME_ID}" "${LOCALISATIONS_DIR}" "${COUNTRIES_DIR}"
    #update-vic3-states "${GAME_ID}" "${LOCALISATIONS_DIR}" "${STATES_DIR}"
    update-vic3-hubs "${GAME_ID}" "${LOCALISATIONS_DIR}"
}

update-vanilla-file \
    "${CK2_LANDED_TITLES_DIR}/landed_titles.txt" \
    "${CK2_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-files \
    "${CK2HIP_VANILLA_LANDED_TITLES_FILE}" \
    "${CK2HIP_LANDED_TITLES_DIR}"/*.txt
update-vanilla-file \
    "${CK2RoI_LANDED_TITLES_DIR}/landed_titles.txt"\
    "${CK2RoI_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-files \
    "${CK2TWK_VANILLA_LANDED_TITLES_FILE}" \
    "${CK2TWK_LANDED_TITLES_DIR}"/*.txt
    #"https://raw.githubusercontent.com/DC123456789/Britannia---The-Winter-King/master/Britannia/common/landed_titles/landed_titles.txt"
update-vanilla-file \
    "${CK3_LANDED_TITLES_DIR}/00_landed_titles.txt" \
    "${CK3_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-files \
    "${CK3AEP_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3AEP_LANDED_TITLES_DIR}"/*.txt
update-vanilla-files \
    "${CK3ATHA_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3ATHA_LANDED_TITLES_DIR}"/*.txt
update-vanilla-files \
    "${CK3CE_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3CE_LANDED_TITLES_DIR}"/*.txt \
    "${CK3_LANDED_TITLES_DIR}"/*.txt
update-vanilla-files \
    "${CK3CMH_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3IBL_LANDED_TITLES_DIR}"/*.txt \
    "${CK3CE_LANDED_TITLES_DIR}"/*.txt \
    "${CK3RICE_LANDED_TITLES_DIR}"/*.txt \
    "${CK3SuccExp_LANDED_TITLES_DIR}"/*.txt \
    "${CK3Trinity_LANDED_TITLES_DIR}"/*.txt
update-vanilla-file \
    "${CK3IBL_LANDED_TITLES_DIR}/00_landed_titles.txt" \
    "${CK3IBL_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-files \
    "${CK3MBP_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3MBP_LANDED_TITLES_DIR}"/*.txt
    #"https://raw.githubusercontent.com/Leviathonlx/MoreBookmarks-Plus/main/common/landed_titles/00_landed_titles.txt"
update-vanilla-file \
    "${CK3SoW_LANDED_TITLES_DIR}/00_landed_titles.txt" \
    "${CK3SoW_VANILLA_LANDED_TITLES_FILE}" \
    "https://gitlab.com/Vertimnus/sinews-of-war/-/raw/main/common/landed_titles/00_landed_titles.txt"
update-vanilla-files \
    "${CK3TBA_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3TBA_LANDED_TITLES_DIR}/"/*.txt
update-vanilla-file \
    "${CK3TFE_LANDED_TITLES_DIR}/00_landed_titles.txt" \
    "${CK3TFE_VANILLA_LANDED_TITLES_FILE}"
update_hoi4_parentage_file \
    'HOI4' \
    "${HOI4_VANILLA_PARENTAGE_FILE}"
update_hoi4_parentage_file \
    'HOI4MDM' \
    "${HOI4MDM_VANILLA_PARENTAGE_FILE}"
update_hoi4_parentage_file \
    'HOI4TGW' \
    "${HOI4TGW_VANILLA_PARENTAGE_FILE}"
update-vanilla-file \
    "${IR_LOCALISATIONS_DIR}/provincenames_l_english.yml" \
    "${IR_VANILLA_FILE}"
update-vanilla-files \
    "${IR_ABW_VANILLA_FILE}" \
    "${IR_ABW_LOCALISATIONS_DIR}/provincenames_l_english.yml"
update-vanilla-files \
    "${IR_AoE_VANILLA_FILE}" \
    "${IR_LOCALISATIONS_DIR}/provincenames_l_english.yml" \
    "${IR_AoE_LOCALISATIONS_DIR}/replace/aoe_provincenames_l_english.yml"
update-vanilla-files \
    "${IR_INV_VANILLA_FILE}" \
    "${IR_INV_LOCALISATIONS_DIR}/provincenames_l_english.yml"
update-vanilla-files \
    "${IR_TI_VANILLA_FILE}" \
    "${IR_TI_LOCALISATIONS_DIR}/provincenames_l_english.yml"
update-vanilla-files \
    "${IR_TBA_VANILLA_FILE}" \
    "${IR_TBA_LOCALISATIONS_DIR}/provincenames_l_english.yml"
update-vic3-files 'Vic3' \
    "${Vic3_LOCALISATIONS_DIR}" \
    "${Vic3_COUNTRIES_DIR}" \
    "${Vic3_STATES_DIR}"
