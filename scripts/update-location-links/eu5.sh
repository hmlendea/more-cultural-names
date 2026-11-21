#!/bin/bash
source "scripts/common/paths.sh"
source "${SCRIPTS_COMMON_DIR}/name_normalisation.sh"
source "${SCRIPTS_COMMON_GAMES_DIR}/eu5.sh"

declare -A EU5_LINKED_LOCATION_IDS=()
declare -A EU5_LINKED_PROVINCE_IDS=()

function loadEu5LinkedIds() {
    local -n TARGET_SET="${1}"
    local LOCATION_TYPE="${2}"
    local LINE

    while IFS= read -r LINE; do
        [ -n "${LINE}" ] && TARGET_SET["${LINE}"]=1
    done < <(grep "GameId game=\"EU5\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" | \
                sed 's/[^>]*>\([^<]*\).*/\1/g')
}

function getEu5Locations() {
    local GAME_ID="${1}"
    local LOCATION_TYPE='Location'
    local LOCATION_OUTPUT_FILE="${REPO_DIR}/${GAME_ID}_locations.txt"
    local LOCATION_ID=''
    local LOCATION_NAME=''

    loadEu5LinkedIds EU5_LINKED_LOCATION_IDS "${LOCATION_TYPE}"

    echo "" > "${LOCATION_OUTPUT_FILE}"

    while IFS= read -r LOCATION_ID; do
        [ -n "${EU5_LINKED_LOCATION_IDS[${LOCATION_ID}]+x}" ] && continue

        LOCATION_NAME="${EU5_LOCATION_NAMES[${LOCATION_ID}]:-}"

        [ -z "${LOCATION_NAME}" ] && continue

        echo "      <GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\">${LOCATION_ID}</GameId> <!-- ${LOCATION_NAME} -->" >> "${LOCATION_OUTPUT_FILE}"

        logLinkableEu5Location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_ID}" "${LOCATION_NAME}"
    done < <(awk -F'=' '{print $1}' "${EU5_VANILLA_LOCATIONS_FILE}" | sort)
}

function getEu5Provinces() {
    local GAME_ID="${1}"
    local LOCATION_TYPE='Province'
    local PROVINCE_OUTPUT_FILE="${REPO_DIR}/${GAME_ID}_provinces.txt"
    local PROVINCE_ID=''
    local PROVINCE_NAME=''

    loadEu5LinkedIds EU5_LINKED_PROVINCE_IDS "${LOCATION_TYPE}"

    echo "" > "${PROVINCE_OUTPUT_FILE}"

    while IFS= read -r PROVINCE_ID; do
        [ -n "${EU5_LINKED_PROVINCE_IDS[${PROVINCE_ID}]+x}" ] && continue

        PROVINCE_NAME="${EU5_PROVINCE_NAMES[${PROVINCE_ID}]:-}"

        [ -z "${PROVINCE_NAME}" ] && continue

        echo "      <GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\">${PROVINCE_ID}</GameId> <!-- ${PROVINCE_NAME} -->" >> "${PROVINCE_OUTPUT_FILE}"

        logLinkableEu5Location "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${PROVINCE_NAME}"
    done < <(awk -F'=' '{print $1}' "${EU5_VANILLA_PROVINCES_FILE}" | sort)
}

loadEu5VanillaNames
loadEu5LocationSets

getEu5Locations "EU5"
getEu5Provinces "EU5"
