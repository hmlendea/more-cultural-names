#!/bin/bash

VANILLA_FILES_DIR="$(pwd)/vanilla"

if [ ! -d "${VANILLA_FILES_DIR}" ]; then
    echo "ERROR: The '${VANILLA_FILES_DIR}' directory does not exist!"
    exit 1
fi

STEAM_APPS_DIR="${HOME}/.local/share/Steam/steamapps"
STEAM_GAMES_DIR="${STEAM_APPS_DIR}/common"
STEAM_WORKSHOP_DIR="${STEAM_APPS_DIR}/workshop"
STEAM_WORKSHOP_CK3_DIR="${STEAM_WORKSHOP_DIR}/content/1158310"
STEAM_WORKSHOP_IR_DIR="${STEAM_WORKSHOP_DIR}/content/859580"
CK2_LOCAL_MODS_DIR="${HOME}/.paradoxinteractive/Crusader Kings II/mod"

CK2_VANILLA_FILE="${VANILLA_FILES_DIR}/ck2_landed_titles.txt"
CK2HIP_VANILLA_FILE="${VANILLA_FILES_DIR}/ck2hip_landed_titles.txt"
CK3_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3_landed_titles.txt"
CK3IBL_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3ibl_landed_titles.txt"
CK3MBP_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3mbp_landed_titles.txt"
CK3TFE_VANILLA_FILE="${VANILLA_FILES_DIR}/ck3tfe_landed_titles.txt"
IR_VANILLA_FILE="${VANILLA_FILES_DIR}/ir_province_names.yml"

function update-vanilla-file() {
    local SOURCE_FILE="${1}"
    local TARGET_FILE="${2}"
    local SOURCE_URL="${3}"

    if [ -f "${SOURCE_FILE}" ]; then
        cp "${SOURCE_FILE}" "${TARGET_FILE}"
    elif [ -n "${SOURCE_URL}" ]; then
        wget -qc --no-check-certificate "${SOURCE_URL}" -O "${TARGET_FILE}" 2>/dev/null
    fi
}

update-vanilla-file \
    "${STEAM_GAMES_DIR}/Crusader Kings II/common/landed_titles/landed_titles.txt" \
    "${CK2_VANILLA_FILE}"
update-vanilla-file \
    "${CK2_LOCAL_MODS_DIR}/Historical_Immersion_Project/common/landed_titles/swmh_landed_titles.txt"\
    "${CK2HIP_VANILLA_FILE}"
update-vanilla-file \
    "${STEAM_GAMES_DIR}/Crusader Kings III/game/common/landed_titles/00_landed_titles.txt" \
    "${CK3_VANILLA_FILE}"
update-vanilla-file \
    "${STEAM_WORKSHOP_CK3_DIR}/2416949291/common/landed_titles/00_landed_titles.txt" \
    "${CK3IBL_VANILLA_FILE}"
update-vanilla-file \
    "${STEAM_WORKSHOP_CK3_DIR}/2216670956/common/landed_titles/00_landed_titles.txt" \
    "${CK3MBP_VANILLA_FILE}" \
    "https://raw.githubusercontent.com/Leviathonlx/MoreBookmarks-Plus/main/common/landed_titles/00_landed_titles.txt"
update-vanilla-file \
    "${STEAM_WORKSHOP_CK3_DIR}/2243307127/common/landed_titles/00_landed_titles.txt" \
    "${CK3TFE_VANILLA_FILE}"
update-vanilla-file \
    "${STEAM_GAMES_DIR}/ImperatorRome/game/localization/english/provincenames_l_english.yml" \
    "${IR_VANILLA_FILE}"
