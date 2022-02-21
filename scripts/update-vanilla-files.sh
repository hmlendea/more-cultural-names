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
    local SOURCE_DIR="${1}"
    local TARGET_FILE="${2}"
    local SOURCE_URL="${3}"

    if [ -d "${SOURCE_DIR}" ]; then
        cat "${SOURCE_DIR}"/*.txt > "${TARGET_FILE}"
    elif [ -n "${SOURCE_URL}" ]; then
        wget -qc --no-check-certificate "${SOURCE_URL}" -O "${TARGET_FILE}" 2>/dev/null
    fi

    if [ -f "${TARGET_FILE}" ]; then
        chmod 755 "${TARGET_FILE}"
        chown "${USER}:${USER}" "${TARGET_FILE}"
        sed -i 's/\r$//' "${TARGET_FILE}"
    fi
}

update-vanilla-file \
    "${CK2_DIR}/common/landed_titles/landed_titles.txt" \
    "${CK2_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${CK2HIP_DIR}/common/landed_titles/swmh_landed_titles.txt"\
    "${CK2HIP_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${CK3_DIR}/game/common/landed_titles/00_landed_titles.txt" \
    "${CK3_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-files \
    "${CK3ATHA_DIR}/common/landed_titles" \
    "${CK3ATHA_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${CK3IBL_DIR}/common/landed_titles/00_landed_titles.txt" \
    "${CK3IBL_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${CK3MBP_DIR}/common/landed_titles/00_landed_titles.txt" \
    "${CK3MBP_VANILLA_LANDED_TITLES_FILE}" \
    "https://raw.githubusercontent.com/Leviathonlx/MoreBookmarks-Plus/main/common/landed_titles/00_landed_titles.txt"
update-vanilla-file \
    "${CK3TFE_DIR}/common/landed_titles/00_landed_titles.txt" \
    "${CK3TFE_VANILLA_LANDED_TITLES_FILE}"
update-vanilla-file \
    "${IR_LOCALISATION_DIR}/provincenames_l_english.yml" \
    "${IR_VANILLA_FILE}"
update-vanilla-file \
    "${IR_AoE_LOCALISATION_DIR}/replace/aoe_provincenames_l_english.yml" \
    "${IR_AoE_VANILLA_FILE}" \
    "https://raw.githubusercontent.com/EliteNinjaX/dark_age_mod/Stable/localization/english/replace/aoe_provincenames_l_english.yml"
