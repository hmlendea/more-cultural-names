#!/bin/bash
source "scripts/common/paths.sh"
source "scripts/common/name_normalisation.sh"
source "scripts/common/hoi4.sh"

function getStates() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local STATES_DIR="${3}"
    local STATES_OUTPUT_FILE="${REPO_DIR}/${GAME_ID}_states.txt"

    echo "" > "${STATES_OUTPUT_FILE}"

    for FILE in "${STATES_DIR}"/*.txt ; do
        local STATE_ID=$(basename "${FILE}" | sed 's/^\([0-9]*\)\s*-\s*.*/\1/g')
        local STATE_NAME=$(getHoi4StateName "${STATE_ID}" "${LOCALISATIONS_DIR}")

        #echo "State #${STATE_ID}: Name='${STATE_NAME}'"
        if $(cat "${LOCATIONS_FILE}" | grep "<GameId game=\"${GAME_ID}\"" | grep "type=\"State\"" | grep -q ">${STATE_ID}<"); then
            sed -i 's/\(^\s*<GameId game=\"'"${GAME_ID}"'\" type=\"State\">'"${STATE_ID}"'<\/GameId>\).*/\1 <!-- '"${STATE_NAME}"' -->/g' "${LOCATIONS_FILE}"
        else
            echo "      <GameId game=\"${GAME_ID}\" type=\"State\">${STATE_ID}</GameId> <!-- ${STATE_NAME} -->" >> "${STATES_OUTPUT_FILE}"

            local LOCATION_ID=$(nameToLocationId "${STATE_NAME}")

            if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
                echo "    > ${GAME_ID}: State #${STATE_ID} (${STATE_NAME}) could potentially be linked with location ${LOCATION_ID}"
            elif grep -q "<!-- ${STATE_NAME} -->" "${LOCATIONS_FILE}"; then
                echo "    > ${GAME_ID}: State #${STATE_ID} (${STATE_NAME}) could potentially be linked with a location with a link with the same default name"
            elif grep -q "value=\"${STATE_NAME}\"" "${LOCATIONS_FILE}"; then
                echo "    > ${GAME_ID}: State #${STATE_ID} (${STATE_NAME}) could potentially be linked with a location with a localisation with the same name"
            fi
        fi
    done
}

function getCities() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local VANILLA_PARENTS_FILE="${3}"
    local CWD="$(pwd)"

    local CITIES_OUTPUT_FILE="${REPO_DIR}/${GAME_ID}_cities.txt"

    echo "" > "${CITIES_OUTPUT_FILE}"

    cd "${LOCALISATIONS_DIR}"
    for CITY_ID in $(find . -name "*victory_points_l_english.yml" | xargs cat | \
                        grep "^\s*VICTORY.*" | \
                        sed 's/^\s*VICTORY_POINTS_\([0-9]*\).*/\1/g' | \
                        sort -h | uniq); do
        local STATE_ID=$(grep "^${CITY_ID}=" "${VANILLA_PARENTS_FILE}" | awk -F = '{print $2}')
        local CITY_NAME=$(getHoi4CityName "${CITY_ID}" "${LOCALISATIONS_DIR}")

        #echo "Province #${CITY_ID}: State=#${STATE_ID} Name='${CITY_NAME}'"
        if grep "<GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | grep "type=\"City\"" | grep -q ">${CITY_ID}<"; then
            sed -i 's/\(^\s*<GameId game=\"'"${GAME_ID}"'\" type=\"City\"\)\( parent=\"[^\"]*\"\)*>'"${CITY_ID}"'<.*/\1 parent=\"'"${STATE_ID}"'\">'"${CITY_ID}"'<\/GameId> <!-- '"${CITY_NAME}"' -->/g' "${LOCATIONS_FILE}"
        else
            echo "      <GameId game=\"${GAME_ID}\" type=\"City\" parent=\"${STATE_ID}\">${CITY_ID}</GameId> <!-- ${CITY_NAME} -->" >> "${CITIES_OUTPUT_FILE}"

            local LOCATION_ID=$(nameToLocationId "${CITY_NAME}")
            local STATE_NAME=$(getHoi4StateName "${STATE_ID}" "${LOCALISATIONS_DIR}")

            if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
                echo "    > ${GAME_ID}: City #${CITY_ID} (${CITY_NAME}) (belonging to state: ${STATE_NAME}) could potentially be linked with location ${LOCATION_ID}"
            elif grep -q "<!-- ${CITY_NAME} -->" "${LOCATIONS_FILE}"; then
                echo "    > ${GAME_ID}: City #${CITY_ID} (${CITY_NAME}) (belonging to state: ${STATE_NAME}) could potentially be linked with a location with a link with the same default name"
            elif grep -q "value=\"${CITY_NAME}\"" "${LOCATIONS_FILE}"; then
                echo "    > ${GAME_ID}: City #${CITY_ID} (${CITY_NAME}) (belonging to state: ${STATE_NAME}) could potentially be linked with a location with a localisation with the same name"
            fi
        fi
    done
    cd "${CWD}"
}

getStates "HOI4" "${HOI4_LOCALISATIONS_DIR}" "${HOI4_STATES_DIR}"
getCities "HOI4" "${HOI4_LOCALISATIONS_DIR}" "${HOI4_VANILLA_PARENTS_FILE}"

getStates "HOI4MDM" "${HOI4MDM_LOCALISATIONS_DIR}" "${HOI4MDM_STATES_DIR}"
getCities "HOI4MDM" "${HOI4MDM_LOCALISATIONS_DIR}" "${HOI4MDM_VANILLA_PARENTS_FILE}"

getStates "HOI4TGW" "${HOI4TGW_LOCALISATIONS_DIR}" "${HOI4TGW_STATES_DIR}"
getCities "HOI4TGW" "${HOI4TGW_LOCALISATIONS_DIR}" "${HOI4TGW_VANILLA_PARENTS_FILE}"
