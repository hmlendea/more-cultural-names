#!/bin/bash
source 'scripts/common/paths.sh'
source "${SCRIPTS_COMMON_DIR}/name_normalisation.sh"

declare -A CIV5_CITY_NAMES=()
declare -A CIV5_CIVILIZATIONS=()
CIV5_DATA_LOADED=''

function load_civ5_data() {
    [[ -n "${CIV5_DATA_LOADED}" ]] && return
    CIV5_DATA_LOADED=true

    if [[ -f "${CIV5_VANILLA_CITY_NAMES_FILE}" ]]; then
        while IFS='=' read -r CITY_KEY CITY_NAME; do
            [[ -n "${CITY_KEY}" ]] && CIV5_CITY_NAMES["${CITY_KEY}"]="${CITY_NAME}"
        done < "${CIV5_VANILLA_CITY_NAMES_FILE}"
    fi

    if [[ -f "${CIV5_VANILLA_CIVILIZATIONS_FILE}" ]]; then
        while IFS= read -r CIVILIZATION_ID; do
            [[ -n "${CIVILIZATION_ID}" ]] && CIV5_CIVILIZATIONS["${CIVILIZATION_ID}"]=1
        done < "${CIV5_VANILLA_CIVILIZATIONS_FILE}"
    fi
}

function get_civ5_city_name() {
    local CITY_KEY="${1}"

    [[ -z "${CITY_KEY// }" ]] && return

    load_civ5_data
    [[ -n "${CIV5_CITY_NAMES[${CITY_KEY}]+x}" ]] && echo "${CIV5_CITY_NAMES[${CITY_KEY}]}"
}

function log_missing_civ5_city() {
    local GAME_ID="${1}"
    local CITY_KEY="${2}"
    local CITY_NAME="${3}"
    local REASON="${4}"

    echo "    > ${GAME_ID}: City ${CITY_KEY} (${CITY_NAME}) could potentially be linked with ${REASON}"
    echo '    <GameIds>'
    echo "      <GameId game=\"${GAME_ID}\">${CITY_KEY}</GameId> <!-- ${CITY_NAME} -->"
    echo '    </GameIds>'
    echo ''
}

function list_missing_civ5_cities() {
    local GAME_ID="${1}"
    local LOCATION_NAME
    local LOCATION_ID

    load_civ5_data

    for CITY_KEY in "${!CIV5_CITY_NAMES[@]}"; do
        grep -q "<GameId game=\"${GAME_ID}\">${CITY_KEY}</GameId>" "${LOCATIONS_FILE}" && continue

        LOCATION_NAME="${CIV5_CITY_NAMES[${CITY_KEY}]}"
        LOCATION_ID="$(nameToLocationId "${LOCATION_NAME}")"

        if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<Id>${LOCATION_ID}</Id>" "${UNUSED_LOCATIONS_FILE}"; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<!-- ${LOCATION_NAME} -->" "${LOCATIONS_FILE}"; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" 'a location with the same default name'
        elif grep -q "value=\"${LOCATION_NAME}\"" "${LOCATIONS_FILE}"; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" 'a location with the same localisation name'
        fi
    done
}

function list_surplus_civ5_cities() {
    local GAME_ID="${1}"
    load_civ5_data

    while IFS= read -r CITY_KEY; do
        [[ -n "${CITY_KEY}" ]] || continue
        [[ -n "${CIV5_CITY_NAMES[${CITY_KEY}]+x}" ]] || \
            echo "    > ${GAME_ID}: City ${CITY_KEY} is defined but it does not exist"
    done < <(grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | sed 's/.*>\([^<]*\)<\/GameId>.*/\1/' | sort -u)
}

function list_missing_civ5_civilizations() {
    local GAME_ID="${1}"
    load_civ5_data

    for CIVILIZATION_ID in "${!CIV5_CIVILIZATIONS[@]}"; do
        grep -q "<GameId game=\"${GAME_ID}\">${CIVILIZATION_ID}</GameId>" "${LANGUAGES_FILE}" || \
            echo "      <GameId game=\"${GAME_ID}\">${CIVILIZATION_ID}</GameId>"
    done
}

function validate_civ5_links() {
    local GAME_ID="${1}"
    [[ -f "${CIV5_VANILLA_CITY_NAMES_FILE}" ]] || return

    list_surplus_civ5_cities "${GAME_ID}"
    # Missing links are intentionally opt-in: the canonical data may contain
    # only the city keys selected for the current edition.
    # list_missing_civ5_cities "${GAME_ID}"
}
