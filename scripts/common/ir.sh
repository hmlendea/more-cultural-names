#!/bin/bash
source 'scripts/common/paths.sh'

function list_missing_ir_provinces() {
    local GAME_ID="${1}"
    local VANILLA_FILE=$(get_variable "${GAME_ID}_VANILLA_FILE")
    local LOCATION_TYPE='Province'

    local LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${LOCATIONS_FILE}")
    local LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${LOCATIONS_FILE}")

    local UNUSED_LOCATIONS_FILE_NAME_LINES=$(grep "<Name language=" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_LOCATIONID_LINES=$(grep "<Id>" "${UNUSED_LOCATIONS_FILE}")
    local UNUSED_LOCATIONS_FILE_GAMEID_LINES=$(grep "<GameId " "${UNUSED_LOCATIONS_FILE}")

    for PROVINCE_ID in $(diff \
                        <(getGameIds "${GAME_ID}") \
                        <( \
                            cat "${VANILLA_FILE}" | \
                            grep "^\s*PROV[0-9][0-9]*:" | \
                            awk -F':' '{print $1}' | \
                            sed 's/^\s*PROV//g' | \
                            sort -u \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        local LOCATION_NAME=$(get_ir_location_name "${GAME_ID}" "${PROVINCE_ID}")

        [ -z "${LOCATION_NAME}" ] && continue

        local LOCATION_ID=$(nameToLocationId "${LOCATION_NAME}")
        local LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

        if grep -q "<Id>${LOCATION_ID}</Id>" <<< "${LOCATIONS_FILE_LOCATIONID_LINES}"; then
            log_missing_ir_province "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${LOCATION_NAME}" "location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<Id>${LOCATION_ID}</Id>" <<< "${UNUSED_LOCATIONS_FILE_LOCATIONID_LINES}"; then
            log_missing_ir_province "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${LOCATION_NAME}" "unused location <Id>${LOCATION_ID}</Id>"
        elif grep -q "<!-- ${LOCATION_NAME} -->" <<< "${LOCATIONS_FILE_GAMEID_LINES}"; then
            log_missing_ir_province "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${LOCATION_NAME}" "a location with a link with the same default name (${LOCATION_NAME})"
        elif grep -q "<!-- ${LOCATION_NAME} -->" <<< "${UNUSED_LOCATIONS_FILE_GAMEID_LINES}"; then
            log_missing_ir_province "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${LOCATION_NAME}" "an unused location with a link with the same default name (${LOCATION_NAME})"
        elif grep -q "value=\"${LOCATION_NAME}\"" <<< "${LOCATIONS_FILE_NAME_LINES}"; then
            log_missing_ir_province "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${LOCATION_NAME}" "a location with a localisation with the same name (${LOCATION_NAME})"
        elif grep -q "value=\"${LOCATION_NAME}\"" <<< "${UNUSED_LOCATIONS_FILE_NAME_LINES}"; then
            log_missing_ir_province "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${LOCATION_NAME}" "an unused location with a localisation with the same name (${LOCATION_NAME})"
        #else
        #    log_missing_ir_province "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${LOCATION_NAME}" 'a new location'
        fi
    done
}

function list_surplus_ir_provinces() {
    local GAME_ID="${1}"
    local VANILLA_FILE=$(get_variable "${GAME_ID}_VANILLA_FILE")

    for PROVINCE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort -u \
                        ) <( \
                            grep -i "^\s*PROV[0-9]*:.*" "${VANILLA_FILE}" | \
                            sed 's/^\s*PROV\([0-9]*\):.*$/\1/g' | \
                            sort -u \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME_ID}: Province ${PROVINCE_ID} is defined but it does not exist. Find it with: ${GAME_ID}\".*>${STATE_ID}<"
    done
}

function log_missing_ir_province() {
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
    echo "      <GameId game=\"${GAME_ID}\">${LOCATION_GAME_ID}</GameId> <!-- ${LOCATION_NAME} -->"
    echo '    </GameIds>'
    echo ''
}

function get_ir_location_name() {
    local GAME_ID="${1}"
    local PROVINCE_ID="${2}"

    [[ -z "${PROVINCE_ID// }" ]] && return

    local VANILLA_FILE=$(get_variable "${GAME_ID}_VANILLA_FILE")

    cat "${VANILLA_FILE}" | \
        grep "^\s*PROV${PROVINCE_ID}:" | \
        sed 's/^\s*PROV'"${PROVINCE_ID}"':[0-9]*\s*\"\([^\"]*\).*/\1/g' | \
        tail -n 1
}
