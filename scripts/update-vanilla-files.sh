#!/bin/bash
source "scripts/common/paths.sh"

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

function update-hoi4-parentage-file() {
    local TARGET_FILE="${1}"
    local STATES_DIR="${2}"

    if [ -f "${TARGET_FILE}" ]; then
        rm "${TARGET_FILE}"
        touch "${TARGET_FILE}"
    fi

    for FILE in "${STATES_DIR}"/*.txt ; do
        local STATE_ID=$(basename "${FILE}" | sed 's/^\([0-9]*\)\s*-\s*.*/\1/g')

        PROVINCE_LIST=$(cat "${FILE}" | \
            sed 's/\r//g' | \
            tr '\n' ' ' | \
            sed 's/\s\s*/ /g' | \
            sed 's/.*provinces\s*=\s*{\([^}]*\).*/\1/g' | \
            sed 's/\(^\s*\|\s*$\)//g')

        for PROVINCE_ID in ${PROVINCE_LIST}; do
            [[ -n "${PROVINCE_LIST// }" ]] && echo "${PROVINCE_ID}=${STATE_ID}" >> "${TARGET_FILE}"
        done
    done
}

update-vanilla-file \
    "${CK2_DIR}/common/landed_titles/landed_titles.txt" \
    "${CK2_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${CK2HIP_DIR}/common/landed_titles/swmh_landed_titles.txt"\
    "${CK2HIP_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${CK2TWK_DIR}/common/landed_titles/landed_titles.txt" \
    "${CK2TWK_VANILLA_LANDED_TITLES_FILE}" #\
    #"https://raw.githubusercontent.com/DC123456789/Britannia---The-Winter-King/master/Britannia/common/landed_titles/landed_titles.txt"
update-vanilla-file \
    "${CK3_DIR}/game/common/landed_titles/00_landed_titles.txt" \
    "${CK3_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-files \
    "${CK3AE_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3AE_LANDED_TITLES_DIR}"/*.txt
update-vanilla-files \
    "${CK3ATHA_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3ATHA_LANDED_TITLES_DIR}"/*.txt
update-vanilla-files \
    "${CK3CE_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3CE_LANDED_TITLES_DIR}"/*.txt \
    "${CK3_LANDED_TITLES_DIR}"/*.txt
update-vanilla-files \
    "${CK3CMH_VANILLA_LANDED_TITLES_FILE}" \
    "${CK3AP_LANDED_TITLES_DIR}"/*.txt \
    "${CK3IBL_LANDED_TITLES_DIR}"/*.txt \
    "${CK3RICE_LANDED_TITLES_DIR}"/*.txt
update-vanilla-file \
    "${CK3IBL_DIR}/common/landed_titles/00_landed_titles.txt" \
    "${CK3IBL_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${CK3MBP_DIR}/common/landed_titles/00_landed_titles.txt" \
    "${CK3MBP_VANILLA_LANDED_TITLES_FILE}" \
    "https://raw.githubusercontent.com/Leviathonlx/MoreBookmarks-Plus/main/common/landed_titles/00_landed_titles.txt"
update-vanilla-file \
    "${CK3SoW_DIR}/common/landed_titles/00_landed_titles.txt" \
    "${CK3SoW_VANILLA_LANDED_TITLES_FILE}" \
    "https://gitlab.com/Vertimnus/sinews-of-war/-/raw/main/common/landed_titles/00_landed_titles.txt"
update-vanilla-file \
    "${CK3TBA_DIR}/common/landed_titles/00_landed_titles.txt" \
    "${CK3TBA_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${CK3TFE_DIR}/common/landed_titles/00_landed_titles.txt" \
    "${CK3TFE_VANILLA_LANDED_TITLES_FILE}"
update-hoi4-parentage-file \
    "${HOI4_VANILLA_PARENTAGE_FILE}" \
    "${HOI4_STATES_DIR}"
update-hoi4-parentage-file \
    "${HOI4MDM_VANILLA_PARENTAGE_FILE}" \
    "${HOI4MDM_STATES_DIR}"
update-hoi4-parentage-file \
    "${HOI4TGW_VANILLA_PARENTAGE_FILE}" \
    "${HOI4TGW_STATES_DIR}"
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
    "${IR_TBA_VANILLA_FILE}" \
    "${IR_TBA_LOCALISATIONS_DIR}/provincenames_l_english.yml"
