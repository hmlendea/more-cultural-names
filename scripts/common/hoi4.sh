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