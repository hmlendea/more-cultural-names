#!/bin/bash
source 'scripts/common/paths.sh'

function list_missing_vic3_hubs() {
    local GAME_ID="${1}"
    local VANILLA_HUBS_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_hubs.txt"
    local LOCATION_TYPE='Hub'

    local LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${LOCATIONS_FILE}")

    local UNUSED_LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${UNUSED_LOCATIONS_FILE}")

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
        local LOCATION_NAME=$(grep "^${HUB_ID}=" "${VANILLA_HUBS_FILE}" | awk -F"=" '{print $2}')

        [ -z "${LOCATION_NAME}" ] && continue

        local LOCATION_ID=$(nameToLocationId "${LOCATION_NAME}")
        local LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

        if grep -q "<Id>${LOCATION_ID}</Id>" <<< "${LOCATIONS_FILE_LOCATIONID_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<Id>${LOCATION_ID}</Id>" <<< "${UNUSED_LOCATIONS_FILE_LOCATIONID_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<!-- ${LOCATION_NAME} -->" <<< "${LOCATIONS_FILE_GAMEID_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "a location with a link with the same default name (${LOCATION_NAME})"
        elif grep -q "<!-- ${LOCATION_NAME} -->" <<< "${UNUSED_LOCATIONS_FILE_GAMEID_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "an unused location with a link with the same default name (${LOCATION_NAME})"
        elif grep -q "value=\"${LOCATION_NAME}\"" <<< "${LOCATIONS_FILE_NAME_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${HUB_ID}" "${LOCATION_NAME}" "a location with a localisation with the same name (${LOCATION_NAME})"
        elif grep -q "value=\"${LOCATION_NAME}\"" <<< "${UNUSED_LOCATIONS_FILE_NAME_LINES}"; then
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

    local LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${LOCATIONS_FILE}")

    local UNUSED_LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${UNUSED_LOCATIONS_FILE}")

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
        local LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

        if grep -q "<Id>${LOCATION_ID}</Id>" <<< "${LOCATIONS_FILE_LOCATIONID_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<Id>${LOCATION_ID}</Id>" <<< "${UNUSED_LOCATIONS_FILE_LOCATIONID_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<!-- ${LOCATION_NAME} -->" <<< "${LOCATIONS_FILE_GAMEID_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "a location with a link with the same default name (${LOCATION_NAME})"
        elif grep -q "<!-- ${LOCATION_NAME} -->" <<< "${UNUSED_LOCATIONS_FILE_GAMEID_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "an unused location with a link with the same default name (${LOCATION_NAME})"
        elif grep -q "value=\"${LOCATION_NAME}\"" <<< "${LOCATIONS_FILE_NAME_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "a location with a localisation with the same name (${LOCATION_NAME})"
        elif grep -q "value=\"${LOCATION_NAME}\"" <<< "${UNUSED_LOCATIONS_FILE_NAME_LINES}"; then
            log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" "an unused location with a localisation with the same name (${LOCATION_NAME})"
        #else
        #    log_missing_vic3_location "${GAME_ID}" "${LOCATION_TYPE}" "${STATE_ID}" "${LOCATION_NAME}" 'a new location'
        fi
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
