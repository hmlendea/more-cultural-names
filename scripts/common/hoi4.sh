#!/bin/bash

function getHoi4CityName() {
    local CITY_ID="${1}"
    local LOCALISATIONS_DIR="${2}"
    local CITY_NAME=""
    local CWD="$(pwd)"

    cd "${LOCALISATIONS_DIR}"
    CITY_NAME=$(find . -name "*victory_points_l_english.yml" | xargs cat | \
                grep "^\s*VICTORY_POINTS_${CITY_ID}:" | \
                sed 's/^\s*VICTORY_POINTS_'"${CITY_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g' | \
                head -n 1)
    cd "${CWD}"

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

    cd "${LOCALISATIONS_DIR}"
    STATE_NAME=$(find . -name "*state_names_l_english.yml" | xargs cat | \
                        grep "^\s*STATE_${STATE_ID}:" | \
                        sed 's/^\s*STATE_'"${STATE_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g')
    cd "${CWD}"

    if [ -z "${STATE_NAME}" ] && [ "${LOCALISATIONS_DIR}" != "${HOI4_LOCALISATIONS_DIR}" ]; then
            STATE_NAME=$(cat "${HOI4_LOCALISATIONS_DIR}/state_names_l_english.yml" | \
                            grep "^\s*STATE_${STATE_ID}:" | \
                            sed 's/^\s*STATE_'"${STATE_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g')
    fi

    echo "${STATE_NAME}"
}

function logHoi4LinkableState() {
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

function logHoi4LinkableCity() {
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