#!/bin/bash
source "scripts/common/paths.sh"
source "${SCRIPTS_COMMON_DIR}/name_normalisation.sh"
source "${SCRIPTS_COMMON_GAMES_DIR}/hoi4.sh"

function logLinkableState() {
    local GAME_ID="${1}"
    local STATE_ID="${2}"
    local STATE_NAME="${3}"
    local REASON="${4}"

    echo "    > ${GAME_ID}: State ${STATE_ID} (${STATE_NAME}) could potentially be linked ${REASON}"
    echo '    <GameIds>'
    echo "      <GameId game=\"${GAME_ID}\" type=\"State\">${STATE_ID}</GameId> <!-- ${STATE_NAME} -->"
    echo '    </GameIds>'
    echo ''
}

function logLinkableCity() {
    local GAME_ID="${1}"
    local CITY_ID="${2}"
    local CITY_NAME="${3}"
    local STATE_ID="${4}"
    local STATE_NAME="${5}"
    local REASON="${6}"

    echo "    > ${GAME_ID}: City #${CITY_ID} (${CITY_NAME}) (State: ${STATE_NAME}) could potentially be linked ${REASON}"
    echo '    <GameIds>'
    echo "      <GameId game=\"${GAME_ID}\" type=\"City\" parent=\"${STATE_ID}\">${CITY_ID}</GameId> <!-- ${CITY_NAME} -->"
    echo '    </GameIds>'
    echo ''
}

function getStates() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local STATES_DIR="${3}"
    local STATES_OUTPUT_FILE="${REPO_DIR}/${GAME_ID}_states.txt"

    local LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_GAME_GAMEID_LINES=$(grep "game=\"${GAME_ID}\"" <<< "${LOCATIONS_FILE_GAMEID_LINES}")

    local UNUSED_LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_GAME_GAMEID_LINES=$(grep "game=\"${GAME_ID}\"" <<< "${UNUSED_LOCATIONS_FILE_GAMEID_LINES}")

    echo "" > "${STATES_OUTPUT_FILE}"

    for FILE in "${STATES_DIR}"/*.txt ; do
        local STATE_ID=$(basename "${FILE}" | sed 's/^\([0-9]*\)\s*-\s*.*/\1/g')

        grep "type=\"State\"" <<< "${LOCATIONS_FILE_GAME_GAMEID_LINES}" | grep -q ">${STATE_ID}<" && continue

        local STATE_NAME=$(getHoi4StateName "${STATE_ID}" "${LOCALISATIONS_DIR}")
        echo "      <GameId game=\"${GAME_ID}\" type=\"State\">${STATE_ID}</GameId> <!-- ${STATE_NAME} -->" >> "${STATES_OUTPUT_FILE}"

        local LOCATION_ID=$(nameToLocationId "${STATE_NAME}")

        if grep -q "<Id>${LOCATION_ID}</Id>" <<< "${LOCATIONS_FILE_LOCATIONID_LINES}"; then
            logLinkableState "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "with location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<Id>${LOCATION_ID}</Id>" <<< "${UNUSED_LOCATIONS_FILE_LOCATIONID_LINES}"; then
            logLinkableState "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "with unused location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<!-- ${STATE_NAME} -->" <<< "${LOCATIONS_FILE_GAMEID_LINES}"; then
            logLinkableState "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "with a location with a link with the same default name (${STATE_NAME})"
        elif grep -q "<!-- ${STATE_NAME} -->" <<< "${UNUSED_LOCATIONS_FILE_GAMEID_LINES}"; then
            logLinkableState "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "with an unused location with a link with the same default name (${STATE_NAME})"
        elif grep -q "value=\"${STATE_NAME}\"" <<< "${LOCATIONS_FILE_NAME_LINES}"; then
            logLinkableState "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "with a location with a localisation with the same name (${STATE_NAME})"
        elif grep -q "value=\"${STATE_NAME}\"" <<< "${UNUSED_LOCATIONS_FILE_NAME_LINES}"; then
            logLinkableState "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "with an unused location with a localisation with the same name (${STATE_NAME})"
        fi
    done
}

function getCities() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local VANILLA_PARENTAGE_FILE="${3}"
    local CWD="$(pwd)"

    if [ ! -f "${VANILLA_PARENTAGE_FILE}" ]; then
        echo "The vanilla parents file for ${GAME_ID} is missing!"
        return
    fi

    local CITIES_OUTPUT_FILE="${REPO_DIR}/${GAME_ID}_cities.txt"

    echo "" > "${CITIES_OUTPUT_FILE}"

    cd "${LOCALISATIONS_DIR}"
    for CITY_ID in $(find . -name "*victory_points_l_english.yml" | xargs cat | \
                        grep "^\s*VICTORY.*" | \
                        sed 's/^\s*VICTORY_POINTS_\([0-9]*\).*/\1/g' | \
                        sort -h | uniq); do
        grep "<GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | grep "type=\"City\"" | grep -q ">${CITY_ID}<" && continue

        local STATE_ID=$(grep "^${CITY_ID}=" "${VANILLA_PARENTAGE_FILE}" | awk -F = '{print $2}')
        local CITY_NAME=$(getHoi4CityName "${CITY_ID}" "${LOCALISATIONS_DIR}")

        echo "      <GameId game=\"${GAME_ID}\" type=\"City\" parent=\"${STATE_ID}\">${CITY_ID}</GameId> <!-- ${CITY_NAME} -->" >> "${CITIES_OUTPUT_FILE}"

        local LOCATION_ID=$(nameToLocationId "${CITY_NAME}")
        local STATE_NAME=$(getHoi4StateName "${STATE_ID}" "${LOCALISATIONS_DIR}")

        if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
            logLinkableCity "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "with location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<Id>${LOCATION_ID}</Id>" "${UNUSED_LOCATIONS_FILE}"; then
            logLinkableCity "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "with unused location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<!-- ${CITY_NAME} -->" "${LOCATIONS_FILE}"; then
            logLinkableCity "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "with a location with a link with the same default name"
        elif grep -q "<!-- ${CITY_NAME} -->" "${UNUSED_LOCATIONS_FILE}"; then
            logLinkableCity "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "with an unused location with a link with the same default name"
        elif grep -q "value=\"${CITY_NAME}\"" "${LOCATIONS_FILE}"; then
            logLinkableCity "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "with a location with a localisation with the same name"
        elif grep -q "value=\"${CITY_NAME}\"" "${UNUSED_LOCATIONS_FILE}"; then
            logLinkableCity "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "with an unused location with a localisation with the same name"
        fi
    done
    cd "${CWD}"
}

getStates "HOI4" "${HOI4_LOCALISATIONS_DIR}" "${HOI4_STATES_DIR}"
getCities "HOI4" "${HOI4_LOCALISATIONS_DIR}" "${HOI4_VANILLA_PARENTAGE_FILE}"

getStates "HOI4MDM" "${HOI4MDM_LOCALISATIONS_DIR}" "${HOI4MDM_STATES_DIR}"
getCities "HOI4MDM" "${HOI4MDM_LOCALISATIONS_DIR}" "${HOI4MDM_VANILLA_PARENTAGE_FILE}"

getStates "HOI4TGW" "${HOI4TGW_LOCALISATIONS_DIR}" "${HOI4TGW_STATES_DIR}"
getCities "HOI4TGW" "${HOI4TGW_LOCALISATIONS_DIR}" "${HOI4TGW_VANILLA_PARENTAGE_FILE}"
