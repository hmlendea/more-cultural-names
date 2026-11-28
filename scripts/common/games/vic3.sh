#!/bin/bash
source 'scripts/common/paths.sh'

declare -A VIC3_LOCATION_IDS=()
declare -A VIC3_UNUSED_LOCATION_IDS=()
declare -A VIC3_LOCATION_GAMEID_COMMENTS=()
declare -A VIC3_UNUSED_LOCATION_GAMEID_COMMENTS=()
declare -A VIC3_LOCATION_NAME_VALUES=()
declare -A VIC3_UNUSED_LOCATION_NAME_VALUES=()
VIC3_LOCATION_SETS_LOADED=''

function addLinesToSet() {
    local -n TARGET_SET="${1}"
    local LINE

    while IFS= read -r LINE; do
        [ -n "${LINE}" ] && TARGET_SET["${LINE}"]=1
    done
}

function loadVic3LocationSets() {
    [ -n "${VIC3_LOCATION_SETS_LOADED}" ] && return
    VIC3_LOCATION_SETS_LOADED=true

    addLinesToSet VIC3_LOCATION_IDS < \
        <(grep "<Id>" "${LOCATIONS_FILE}" | sed -n 's/^\s*<Id>\(.*\)<\/Id>.*/\1/p')
    addLinesToSet VIC3_UNUSED_LOCATION_IDS < \
        <(grep "<Id>" "${UNUSED_LOCATIONS_FILE}" | sed -n 's/^\s*<Id>\(.*\)<\/Id>.*/\1/p')
    addLinesToSet VIC3_LOCATION_GAMEID_COMMENTS < \
        <(grep "<GameId " "${LOCATIONS_FILE}" | sed -n 's/.*<!-- \(.*\) -->.*/\1/p')
    addLinesToSet VIC3_UNUSED_LOCATION_GAMEID_COMMENTS < \
        <(grep "<GameId " "${UNUSED_LOCATIONS_FILE}" | sed -n 's/.*<!-- \(.*\) -->.*/\1/p')
    addLinesToSet VIC3_LOCATION_NAME_VALUES < \
        <(grep "<Name language=" "${LOCATIONS_FILE}" | sed -n 's/.*value="\([^"]*\)".*/\1/p')
    addLinesToSet VIC3_UNUSED_LOCATION_NAME_VALUES < \
        <(grep "<Name language=" "${UNUSED_LOCATIONS_FILE}" | sed -n 's/.*value="\([^"]*\)".*/\1/p')
}

function isVic3HubCultureVariant() {
    local HUB_ID="${1}"

    [[ ${HUB_ID} =~ _(city|farm|mine|port|wood)_ ]]
}

function list_missing_vic3_hubs() {
    local GAME_ID="${1}"
    local VANILLA_HUBS_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_hubs.txt"
    local LOCATION_TYPE='Hub'

    loadVic3LocationSets

    for HUB_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" |
                            sed 's/.*>\([^<]*\)<\/GameId.*/\1/g' |
                            sort | uniq \
                        ) <( \
                            cat "${VANILLA_HUBS_FILE}" | \
                            awk -F"=" '{print $1}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        isVic3HubCultureVariant "${HUB_ID}" && continue

        local LOCATION_NAME=$(grep "^${HUB_ID}=" "${VANILLA_HUBS_FILE}" | awk -F"=" '{print $2}')

        [ -z "${LOCATION_NAME}" ] && continue

        local LOCATION_ID=$(nameToLocationId "${LOCATION_NAME}")

        if [ -n "${LOCATION_ID}" ] && [ -n "${VIC3_LOCATION_IDS[${LOCATION_ID}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif [ -n "${LOCATION_ID}" ] && [ -n "${VIC3_UNUSED_LOCATION_IDS[${LOCATION_ID}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif [ -n "${VIC3_LOCATION_GAMEID_COMMENTS[${LOCATION_NAME}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "a location with a link with the same default name (${LOCATION_NAME})"
        elif [ -n "${VIC3_UNUSED_LOCATION_GAMEID_COMMENTS[${LOCATION_NAME}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "an unused location with a link with the same default name (${LOCATION_NAME})"
        elif [ -n "${VIC3_LOCATION_NAME_VALUES[${LOCATION_NAME}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "a location with a localisation with the same name (${LOCATION_NAME})"
        elif [ -n "${VIC3_UNUSED_LOCATION_NAME_VALUES[${LOCATION_NAME}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "an unused location with a localisation with the same name (${LOCATION_NAME})"
        #else
        #    log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" 'a new location'
        fi
    done
}

function list_missing_vic3_states() {
    local GAME_ID="${1}"
    local VANILLA_STATES_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_states.txt"
    local LOCATION_TYPE='State'

    loadVic3LocationSets

    for STATE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" |
                            sed 's/.*>\([^<]*\)<\/GameId.*/\1/g' |
                            sort | uniq \
                        ) <( \
                            cat "${VANILLA_STATES_FILE}" | \
                            awk -F"=" '{print $1}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        local LOCATION_NAME=$(grep "^${STATE_ID}=" "${VANILLA_STATES_FILE}" | awk -F"=" '{print $2}')

        [ -z "${LOCATION_NAME}" ] && continue

        local LOCATION_ID=$(nameToLocationId "${LOCATION_NAME}")

        if [ -n "${LOCATION_ID}" ] && [ -n "${VIC3_LOCATION_IDS[${LOCATION_ID}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif [ -n "${LOCATION_ID}" ] && [ -n "${VIC3_UNUSED_LOCATION_IDS[${LOCATION_ID}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif [ -n "${VIC3_LOCATION_GAMEID_COMMENTS[${LOCATION_NAME}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "a location with a link with the same default name (${LOCATION_NAME})"
        elif [ -n "${VIC3_UNUSED_LOCATION_GAMEID_COMMENTS[${LOCATION_NAME}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "an unused location with a link with the same default name (${LOCATION_NAME})"
        elif [ -n "${VIC3_LOCATION_NAME_VALUES[${LOCATION_NAME}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "a location with a localisation with the same name (${LOCATION_NAME})"
        elif [ -n "${VIC3_UNUSED_LOCATION_NAME_VALUES[${LOCATION_NAME}]+x}" ]; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "an unused location with a localisation with the same name (${LOCATION_NAME})"
        #else
        #    log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" 'a new location'
        fi
    done
}

function list_surplus_vic3_hubs() {
    local GAME_ID="${1}"
    local VANILLA_HUBS_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_hubs.txt"
    local LOCATION_TYPE='Hub'


    for HUB_ID in $(diff \
                        <( \
                            cat "${VANILLA_HUBS_FILE}" | \
                            awk -F"=" '{print $1}' | \
                            sort | uniq \
                        ) <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" |
                            sed 's/.*>\([^<]*\)<\/GameId.*/\1/g' |
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        echo "    > ${GAME_ID}: ${LOCATION_TYPE} ${HUB_ID} is defined but it does not exist. Find it with: ${GAME_ID}[^A-Z].*${LOCATION_TYPE}.*>${HUB_ID}<"
    done
}

function list_surplus_vic3_states() {
    local GAME_ID="${1}"
    local VANILLA_STATES_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_states.txt"
    local LOCATION_TYPE='State'

    for STATE_ID in $(diff \
                        <( \
                            cat "${VANILLA_STATES_FILE}" | \
                            awk -F"=" '{print $1}' | \
                            sort | uniq \
                        ) <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" |
                            sed 's/.*>\([^<]*\)<\/GameId.*/\1/g' |
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        echo "    > ${GAME_ID}: ${LOCATION_TYPE} ${HUB_ID} is defined but it does not exist. Find it with: ${GAME_ID}[^A-Z].*${LOCATION_TYPE}.*>${HUB_ID}<"
    done
}

function log_missing_vic3_location() {
    local GAME_ID="${1}"
    local LOCATION_TYPE="${2}"
    local LOCATION_GAME_ID="${3}"
    local LOCATION_NAME="${4}"
    local REASON="${5}"

    if [ "${LOCATION_TYPE}" = 'Hub' ]; then
        local STATE_ID=$(echo "${LOCATION_GAME_ID}" | sed 's/^\(STATE_[A-Z_]*\)_[a-z].*$/\1/g')
        local STATE_NAME=$(grep "^${STATE_ID}=" "${VANILLA_FILES_DIR}/${GAME_ID}_states.txt" | awk -F"=" '{print $2}')

        echo "    > ${GAME_ID}: ${LOCATION_TYPE} ${LOCATION_GAME_ID} (${LOCATION_NAME}) (State: ${STATE_NAME}) could potentially be linked with ${REASON}"
    else
        echo "    > ${GAME_ID}: ${LOCATION_TYPE} ${LOCATION_GAME_ID} (${LOCATION_NAME}) could potentially be linked with ${REASON}"
    fi

    echo '    <GameIds>'
    echo "      <GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\">${LOCATION_GAME_ID}</GameId> <!-- ${LOCATION_NAME} -->"
    echo '    </GameIds>'
    echo ''
}
