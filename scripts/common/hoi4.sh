#!/bin/bash
source "scripts/common/paths.sh"

function checkForMissingHoi4CityLinks() {
    local GAME_ID="${1}"
    local VANILLA_FILE=$(get_variable "${GAME_ID}_VANILLA_PARENTAGE_FILE")
    local LOCALISATIONS_DIR=$(get_variable "${GAME_ID}_LOCALISATIONS_DIR")
    local CWD="$(pwd)"

    if  ! find "${LOCALISATIONS_DIR}" -name '*.yml' -exec cat {} + 2>/dev/null | grep -q 'VICTORY_POINTS'; then
        LOCALISATIONS_DIR="${HOI4_LOCALISATIONS_DIR}"
    fi

    if [ ! -f "${VANILLA_FILE}" ]; then
        echo "The vanilla parents file (${VANILLA_FILE}) for ${GAME_ID} is missing!"
        return
    fi

    for CITY_ID in $(cat "${VANILLA_FILE}" | \
                        awk -F'=' '{print $1}' | \
                        sort -h | uniq); do
        grep "<GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | grep "type=\"City\"" | grep -q ">${CITY_ID}<" && continue

        local CITY_NAME=$(getHoi4CityName "${CITY_ID}" "${LOCALISATIONS_DIR}")

        [ -z "${CITY_NAME}" ] && continue

        local STATE_ID=$(grep "^${CITY_ID}=" "${VANILLA_FILE}" | awk -F = '{print $2}')

        local LOCATION_ID=$(nameToLocationId "${CITY_NAME}")
        local STATE_NAME=$(getHoi4StateName "${STATE_ID}" "${LOCALISATIONS_DIR}")

        if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
            logLinkableHoi4City "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<Id>${LOCATION_ID}</Id>" "${UNUSED_LOCATIONS_FILE}"; then
            logLinkableHoi4City "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<!-- ${CITY_NAME} -->" "${LOCATIONS_FILE}"; then
            logLinkableHoi4City "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "a location with a link with the same default name"
        elif grep -q "<!-- ${CITY_NAME} -->" "${UNUSED_LOCATIONS_FILE}"; then
            logLinkableHoi4City "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "an unused location with a link with the same default name"
        elif grep -q "value=\"${CITY_NAME}\"" "${LOCATIONS_FILE}"; then
            logLinkableHoi4City "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "a location with a localisation with the same name"
        elif grep -q "value=\"${CITY_NAME}\"" "${UNUSED_LOCATIONS_FILE}"; then
            logLinkableHoi4City "${GAME_ID}" "${CITY_ID}" "${CITY_NAME}" "${STATE_ID}" "${STATE_NAME}" "an unused location with a localisation with the same name"
        fi
    done
}

function checkForMissingHoi4StateLinks() {
    local GAME_ID="${1}"
    local VANILLA_FILE=$(get_variable "${GAME_ID}_VANILLA_PARENTAGE_FILE")
    local LOCALISATIONS_DIR=$(get_variable "${GAME_ID}_LOCALISATIONS_DIR")
    local STATES_DIR=$(get_variable "${GAME_ID}_STATES_DIR")
    local CWD="$(pwd)"

    local LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_GAME_GAMEID_LINES=$(grep "game=\"${GAME_ID}\"" <<< "${LOCATIONS_FILE_GAMEID_LINES}")

    local UNUSED_LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_GAME_GAMEID_LINES=$(grep "game=\"${GAME_ID}\"" <<< "${UNUSED_LOCATIONS_FILE_GAMEID_LINES}")

    for STATE_ID in $(cat "${VANILLA_FILE}" | \
                        awk -F'=' '{print $2}' | \
                        sort -h | uniq); do
        grep "type=\"State\"" <<< "${LOCATIONS_FILE_GAME_GAMEID_LINES}" | grep -q ">${STATE_ID}<" && continue

        local STATE_NAME=$(getHoi4StateName "${STATE_ID}" "${LOCALISATIONS_DIR}")
        local LOCATION_ID=$(nameToLocationId "${STATE_NAME}")

        if grep -q "<Id>${LOCATION_ID}</Id>" <<< "${LOCATIONS_FILE_LOCATIONID_LINES}"; then
            logLinkableHoi4State "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<Id>${LOCATION_ID}</Id>" <<< "${UNUSED_LOCATIONS_FILE_LOCATIONID_LINES}"; then
            logLinkableHoi4State "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<!-- ${STATE_NAME} -->" <<< "${LOCATIONS_FILE_GAMEID_LINES}"; then
            logLinkableHoi4State "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "a location with a link with the same default name (${STATE_NAME})"
        elif grep -q "<!-- ${STATE_NAME} -->" <<< "${UNUSED_LOCATIONS_FILE_GAMEID_LINES}"; then
            logLinkableHoi4State "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "an unused location with a link with the same default name (${STATE_NAME})"
        elif grep -q "value=\"${STATE_NAME}\"" <<< "${LOCATIONS_FILE_NAME_LINES}"; then
            logLinkableHoi4State "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "a location with a localisation with the same name (${STATE_NAME})"
        elif grep -q "value=\"${STATE_NAME}\"" <<< "${UNUSED_LOCATIONS_FILE_NAME_LINES}"; then
            logLinkableHoi4State "${GAME_ID}" "${STATE_ID}" "${STATE_NAME}" "an unused location with a localisation with the same name (${STATE_NAME})"
        fi
    done
}

function checkForMissingHoi4LocationLinks() {
    local GAME_ID="${1}"

    checkForMissingHoi4StateLinks "${GAME_ID}"
    checkForMissingHoi4CityLinks "${GAME_ID}"
}

function checkForSurplusHoi4CityLinks() {
    local GAME_ID="${1}"
    local VANILLA_FILE=$(get_variable "${GAME_ID}_VANILLA_PARENTAGE_FILE")
    local LOCALISATIONS_DIR=$(get_variable "${GAME_ID}_LOCALISATIONS_DIR")

    if  ! find "${LOCALISATIONS_DIR}" -name '*.yml' -exec cat {} + 2>/dev/null | grep -q 'VICTORY_POINTS'; then
        LOCALISATIONS_DIR="${HOI4_LOCALISATIONS_DIR}"
    fi

    for CITY_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | grep "type=\"City\"" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort -h | uniq \
                        ) <( \
                            cat "${VANILLA_FILE}" | \
                            awk -F'=' '{print $1}' | \
                            sort -h | uniq \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME_ID}: City ${CITY_ID} is defined but it does not exist. Find it with: ${GAME_ID}[^A-Z].*City.*>${CITY_ID}<"
    done
}

function checkForSurplusHoi4StateLinks() {
    local GAME_ID="${1}"
    local VANILLA_FILE=$(get_variable "${GAME_ID}_VANILLA_PARENTAGE_FILE")
    local LOCALISATIONS_DIR=$(get_variable "${GAME_ID}_LOCALISATIONS_DIR")

    if  ! find "${LOCALISATIONS_DIR}" -name '*.yml' -exec cat {} + 2>/dev/null | grep -q 'STATE_[1-9][0-9]*:'; then
        LOCALISATIONS_DIR="${HOI4_LOCALISATIONS_DIR}"
    fi

    for STATE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | grep "type=\"State\"" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort -h | uniq \
                        ) <( \
                            cat "${VANILLA_FILE}" | \
                            awk -F'=' '{print $2}' | \
                            sort -h | uniq \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME_ID}: State ${STATE_ID} is defined but it does not exist. Find it with: ${GAME_ID}[^A-Z].*State.*>${STATE_ID}<"
    done
}

function checkForSurplusHoi4LocationLinks() {
    local GAME_ID="${1}"

    checkForSurplusHoi4CityLinks "${GAME_ID}"
    checkForSurplusHoi4StateLinks "${GAME_ID}"
}

function getHoi4CityName() {
    local CITY_ID="${1}"

    [[ -z "${CITY_ID// }" ]] && return

    local LOCALISATIONS_DIR="${2}"
    local CITY_NAME=""
    local CWD="$(pwd)"

    if [[ "${LOCALISATIONS_DIR}" != */english ]]; then
        LOCALISATIONS_DIR="${LOCALISATIONS_DIR%/}/english"
    fi

    CITY_NAME=$(find "${LOCALISATIONS_DIR}" -name '*.yml' -exec cat {} + | \
                grep "^\s*VICTORY_POINTS_${CITY_ID}:" | \
                sed 's/^\s*VICTORY_POINTS_'"${CITY_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g' | \
                head -n 1)

    if [ -z "${CITY_NAME}" ] && [ "${LOCALISATIONS_DIR}" != "${HOI4_LOCALISATIONS_DIR}" ]; then
        CITY_NAME=$(cat "${HOI4_LOCALISATIONS_DIR}/victory_points_l_english.yml" | \
                    grep "^\s*VICTORY_POINTS_${CITY_ID}:" | \
                    sed 's/^\s*VICTORY_POINTS_'"${CITY_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g' | \
                head -n 1)
    fi

    echo "${CITY_NAME}"
}

function getHoi4StateName() {
    local STATE_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local STATE_NAME=""
    local CWD="$(pwd)"

    if [[ "${LOCALISATIONS_DIR}" != */english ]]; then
        LOCALISATIONS_DIR="${LOCALISATIONS_DIR%/}/english"
    fi

    STATE_NAME=$(find "${LOCALISATIONS_DIR}" -name '*.yml' -exec cat {} + | \
                        grep "^\s*STATE_${STATE_ID}:" | \
                        sed 's/^\s*STATE_'"${STATE_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g')

    if [ -z "${STATE_NAME}" ] && [ "${LOCALISATIONS_DIR}" != "${HOI4_LOCALISATIONS_DIR}" ]; then
            STATE_NAME=$(cat "${HOI4_LOCALISATIONS_DIR}/state_names_l_english.yml" | \
                            grep "^\s*STATE_${STATE_ID}:" | \
                            sed 's/^\s*STATE_'"${STATE_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g')
    fi

    echo "${STATE_NAME}"
}

function logLinkableHoi4State() {
    local GAME_ID="${1}"
    local STATE_ID="${2}"
    local STATE_NAME="${3}"
    local REASON="${4}"

    echo "    > ${GAME_ID}: State ${STATE_ID} (${STATE_NAME}) could potentially be linked with ${REASON}"
    echo '    <GameIds>'
    echo "      <GameId game=\"${GAME_ID}\" type=\"State\">${STATE_ID}</GameId> <!-- ${STATE_NAME} -->"
    echo '    </GameIds>'
    echo ''
}

function logLinkableHoi4City() {
    local GAME_ID="${1}"
    local CITY_ID="${2}"
    local CITY_NAME="${3}"
    local STATE_ID="${4}"
    local STATE_NAME="${5}"
    local REASON="${6}"

    echo "    > ${GAME_ID}: City #${CITY_ID} (${CITY_NAME}) (State: ${STATE_NAME}) could potentially be linked with ${REASON}"
    echo '    <GameIds>'
    echo "      <GameId game=\"${GAME_ID}\" type=\"City\" parent=\"${STATE_ID}\">${CITY_ID}</GameId> <!-- ${CITY_NAME} -->"
    echo '    </GameIds>'
    echo ''
}