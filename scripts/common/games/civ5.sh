#!/bin/bash
source 'scripts/common/paths.sh'
source "${SCRIPTS_COMMON_DIR}/name_normalisation.sh"

declare -A CIV5_CITY_NAMES=()
declare -A CIV5_CIVILIZATIONS=()
declare -A CIV5_LINKED_CITY_KEYS=()
declare -A CIV5_LOCATION_IDS=()
declare -A CIV5_UNUSED_LOCATION_IDS=()
declare -A CIV5_LOCATION_GAMEID_COMMENTS=()
declare -A CIV5_UNUSED_LOCATION_GAMEID_COMMENTS=()
declare -A CIV5_LOCATION_NAME_VALUES=()
declare -A CIV5_UNUSED_LOCATION_NAME_VALUES=()
CIV5_CITY_NAMES_LOADED=''
CIV5_CIVILIZATIONS_LOADED=''
CIV5_LOCATION_SETS_LOADED=''

function addLinesToCiv5Set() {
    local -n TARGET_SET="${1}"
    local LINE

    while IFS= read -r LINE; do
        [ -n "${LINE}" ] && TARGET_SET["${LINE}"]=1
    done
}

function loadCiv5CityNames() {
    [ -n "${CIV5_CITY_NAMES_LOADED}" ] && return
    CIV5_CITY_NAMES_LOADED=true

    local CITY_KEY=''
    local CITY_NAME=''

    [ ! -f "${CIV5_VANILLA_CITY_NAMES_FILE}" ] && return

    while IFS='=' read -r CITY_KEY CITY_NAME; do
        [ -n "${CITY_KEY}" ] && CIV5_CITY_NAMES["${CITY_KEY}"]="${CITY_NAME}"
    done < "${CIV5_VANILLA_CITY_NAMES_FILE}"
}

function loadCiv5Civilizations() {
    [ -n "${CIV5_CIVILIZATIONS_LOADED}" ] && return
    CIV5_CIVILIZATIONS_LOADED=true

    [ ! -f "${CIV5_VANILLA_CIVILIZATIONS_FILE}" ] && return

    addLinesToCiv5Set CIV5_CIVILIZATIONS < "${CIV5_VANILLA_CIVILIZATIONS_FILE}"
}

function loadCiv5LocationSets() {
    [ -n "${CIV5_LOCATION_SETS_LOADED}" ] && return
    CIV5_LOCATION_SETS_LOADED=true

    addLinesToCiv5Set CIV5_LOCATION_IDS < \
        <(grep "<Id>" "${LOCATIONS_FILE}" | sed -n 's/^\s*<Id>\(.*\)<\/Id>.*/\1/p')
    addLinesToCiv5Set CIV5_UNUSED_LOCATION_IDS < \
        <(grep "<Id>" "${UNUSED_LOCATIONS_FILE}" | sed -n 's/^\s*<Id>\(.*\)<\/Id>.*/\1/p')
    addLinesToCiv5Set CIV5_LOCATION_GAMEID_COMMENTS < \
        <(grep "<GameId " "${LOCATIONS_FILE}" | sed -n 's/.*<!-- \(.*\) -->.*/\1/p')
    addLinesToCiv5Set CIV5_UNUSED_LOCATION_GAMEID_COMMENTS < \
        <(grep "<GameId " "${UNUSED_LOCATIONS_FILE}" | sed -n 's/.*<!-- \(.*\) -->.*/\1/p')
    addLinesToCiv5Set CIV5_LOCATION_NAME_VALUES < \
        <(grep "<Name language=" "${LOCATIONS_FILE}" | sed -n 's/.*value="\([^"]*\)".*/\1/p')
    addLinesToCiv5Set CIV5_UNUSED_LOCATION_NAME_VALUES < \
        <(grep "<Name language=" "${UNUSED_LOCATIONS_FILE}" | sed -n 's/.*value="\([^"]*\)".*/\1/p')
}

function loadCiv5LinkedCityKeys() {
    local GAME_ID="${1}"
    local CITY_KEY=''

    while IFS= read -r CITY_KEY; do
        [ -n "${CITY_KEY}" ] && CIV5_LINKED_CITY_KEYS["${CITY_KEY}"]=1
    done < <(grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                sed 's/.*>\([^<]*\)<\/GameId>.*/\1/')
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
    local CITY_KEY=''
    local LOCATION_NAME=''
    local LOCATION_ID=''

    loadCiv5CityNames
    loadCiv5LocationSets

    for CITY_KEY in "${!CIV5_CITY_NAMES[@]}"; do
        [ -n "${CIV5_LINKED_CITY_KEYS[${CITY_KEY}]+x}" ] && continue

        LOCATION_NAME="${CIV5_CITY_NAMES[${CITY_KEY}]}"
        LOCATION_ID=$(nameToLocationId "${LOCATION_NAME}")

        if [ -n "${LOCATION_ID}" ] && [ -n "${CIV5_LOCATION_IDS[${LOCATION_ID}]+x}" ]; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif [ -n "${LOCATION_ID}" ] && [ -n "${CIV5_UNUSED_LOCATION_IDS[${LOCATION_ID}]+x}" ]; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif [ -n "${CIV5_LOCATION_GAMEID_COMMENTS[${LOCATION_NAME}]+x}" ]; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" "a location with a link with the same default name (${LOCATION_NAME})"
        elif [ -n "${CIV5_UNUSED_LOCATION_GAMEID_COMMENTS[${LOCATION_NAME}]+x}" ]; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" "an unused location with a link with the same default name (${LOCATION_NAME})"
        elif [ -n "${CIV5_LOCATION_NAME_VALUES[${LOCATION_NAME}]+x}" ]; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" "a location with a localisation with the same name (${LOCATION_NAME})"
        elif [ -n "${CIV5_UNUSED_LOCATION_NAME_VALUES[${LOCATION_NAME}]+x}" ]; then
            log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" "an unused location with a localisation with the same name (${LOCATION_NAME})"
        #else
        #    log_missing_civ5_city "${GAME_ID}" "${CITY_KEY}" "${LOCATION_NAME}" 'a new location'
        fi
    done
}

function list_surplus_civ5_cities() {
    local GAME_ID="${1}"
    local CITY_KEY=''

    loadCiv5CityNames

    for CITY_KEY in "${!CIV5_LINKED_CITY_KEYS[@]}"; do
        [ -n "${CIV5_CITY_NAMES[${CITY_KEY}]+x}" ] || \
            echo "    > ${GAME_ID}: City ${CITY_KEY} is defined but it does not exist"
    done
}

function list_surplus_civ5_civilizations() {
    local GAME_ID="${1}"
    local CIVILIZATION_ID=''

    loadCiv5Civilizations

    while IFS= read -r CIVILIZATION_ID; do
        [ -n "${CIVILIZATION_ID}" ] || continue
        [ -n "${CIV5_CIVILIZATIONS[${CIVILIZATION_ID}]+x}" ] || \
            echo "    > ${GAME_ID}: Civilization ${CIVILIZATION_ID} is defined but it does not exist"
    done < <(grep "GameId game=\"${GAME_ID}\"" "${LANGUAGES_FILE}" | \
                sed 's/.*>\([^<]*\)<\/GameId>.*/\1/' | sort -u)
}

function validate_civ5_links() {
    local GAME_ID="${1}"
    [ -f "${CIV5_VANILLA_CITY_NAMES_FILE}" ] || return

    loadCiv5CityNames
    loadCiv5LinkedCityKeys "${GAME_ID}"

    list_missing_civ5_cities "${GAME_ID}"
    list_surplus_civ5_cities "${GAME_ID}"
    list_surplus_civ5_civilizations "${GAME_ID}"
}
