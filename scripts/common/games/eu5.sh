#!/bin/bash
source 'scripts/common/paths.sh'

declare -A EU5_LOCATION_NAMES=()
declare -A EU5_PROVINCE_NAMES=()
declare -A EU5_LOCATION_IDS=()
declare -A EU5_UNUSED_LOCATION_IDS=()
declare -A EU5_LOCATION_GAMEID_COMMENTS=()
declare -A EU5_UNUSED_LOCATION_GAMEID_COMMENTS=()
declare -A EU5_LOCATION_NAME_VALUES=()
declare -A EU5_UNUSED_LOCATION_NAME_VALUES=()
declare -A EU5_LOCATION_PROVINCES=()
declare -A EU5_PROVINCE_AREAS=()
declare -A EU5_AREA_NAMES=()
EU5_LOCATION_SETS_LOADED=''
EU5_VANILLA_NAMES_LOADED=''
EU5_PARENTAGE_LOADED=''

function addLinesToEu5Set() {
    local -n TARGET_SET="${1}"
    local LINE

    while IFS= read -r LINE; do
        [ -n "${LINE}" ] && TARGET_SET["${LINE}"]=1
    done
}

function loadEu5LocationSets() {
    [ -n "${EU5_LOCATION_SETS_LOADED}" ] && return
    EU5_LOCATION_SETS_LOADED=true

    addLinesToEu5Set EU5_LOCATION_IDS < \
        <(grep "<Id>" "${LOCATIONS_FILE}" | sed -n 's/^\s*<Id>\(.*\)<\/Id>.*/\1/p')
    addLinesToEu5Set EU5_UNUSED_LOCATION_IDS < \
        <(grep "<Id>" "${UNUSED_LOCATIONS_FILE}" | sed -n 's/^\s*<Id>\(.*\)<\/Id>.*/\1/p')
    addLinesToEu5Set EU5_LOCATION_GAMEID_COMMENTS < \
        <(grep "<GameId " "${LOCATIONS_FILE}" | sed -n 's/.*<!-- \(.*\) -->.*/\1/p')
    addLinesToEu5Set EU5_UNUSED_LOCATION_GAMEID_COMMENTS < \
        <(grep "<GameId " "${UNUSED_LOCATIONS_FILE}" | sed -n 's/.*<!-- \(.*\) -->.*/\1/p')
    addLinesToEu5Set EU5_LOCATION_NAME_VALUES < \
        <(grep "<Name language=" "${LOCATIONS_FILE}" | sed -n 's/.*value="\([^"]*\)".*/\1/p')
    addLinesToEu5Set EU5_UNUSED_LOCATION_NAME_VALUES < \
        <(grep "<Name language=" "${UNUSED_LOCATIONS_FILE}" | sed -n 's/.*value="\([^"]*\)".*/\1/p')
}

function loadEu5VanillaNames() {
    [ -n "${EU5_VANILLA_NAMES_LOADED}" ] && return
    EU5_VANILLA_NAMES_LOADED=true

    local SNAPSHOT_FILE=''
    local ENTRY_ID=''
    local ENTRY_NAME=''

    SNAPSHOT_FILE="${EU5_VANILLA_LOCATIONS_FILE}"

    if [ -f "${SNAPSHOT_FILE}" ]; then
        while IFS='=' read -r ENTRY_ID ENTRY_NAME; do
            [ -n "${ENTRY_ID}" ] && EU5_LOCATION_NAMES["${ENTRY_ID}"]="${ENTRY_NAME}"
        done < "${SNAPSHOT_FILE}"
    fi

    SNAPSHOT_FILE="${EU5_VANILLA_PROVINCES_FILE}"

    if [ -f "${SNAPSHOT_FILE}" ]; then
        while IFS='=' read -r ENTRY_ID ENTRY_NAME; do
            [ -n "${ENTRY_ID}" ] && EU5_PROVINCE_NAMES["${ENTRY_ID}"]="${ENTRY_NAME}"
        done < "${SNAPSHOT_FILE}"
    fi
}

function loadEu5Parentage() {
    [ -n "${EU5_PARENTAGE_LOADED}" ] && return
    EU5_PARENTAGE_LOADED=true

    local SNAPSHOT_FILE=''
    local ENTRY_KEY=''
    local ENTRY_VALUE=''

    SNAPSHOT_FILE="${EU5_VANILLA_PARENTAGE_FILE}"

    if [ -f "${SNAPSHOT_FILE}" ]; then
        while IFS='=' read -r ENTRY_KEY ENTRY_VALUE; do
            [ -z "${ENTRY_KEY}" ] && continue

            if [[ ${ENTRY_VALUE} == *_area ]]; then
                EU5_PROVINCE_AREAS["${ENTRY_KEY}"]="${ENTRY_VALUE}"
            else
                EU5_LOCATION_PROVINCES["${ENTRY_KEY}"]="${ENTRY_VALUE}"
            fi
        done < "${SNAPSHOT_FILE}"
    fi

    SNAPSHOT_FILE="${EU5_VANILLA_AREAS_FILE}"

    if [ -f "${SNAPSHOT_FILE}" ]; then
        while IFS='=' read -r ENTRY_KEY ENTRY_VALUE; do
            [ -n "${ENTRY_KEY}" ] && EU5_AREA_NAMES["${ENTRY_KEY}"]="${ENTRY_VALUE}"
        done < "${SNAPSHOT_FILE}"
    fi
}

function getEu5ContainerContext() {
    local LOCATION_GAME_ID="${1}"
    local LOCATION_TYPE="${2}"
    local PROVINCE_ID=''
    local PROVINCE_NAME=''
    local AREA_ID=''
    local AREA_NAME=''

    if [ "${LOCATION_TYPE}" = 'Province' ]; then
        AREA_ID="${EU5_PROVINCE_AREAS[${LOCATION_GAME_ID}]:-}"

        [ -z "${AREA_ID}" ] && return

        echo " (Area: ${EU5_AREA_NAMES[${AREA_ID}]:-${AREA_ID}})"
        return
    fi

    PROVINCE_ID="${EU5_LOCATION_PROVINCES[${LOCATION_GAME_ID}]:-}"

    [ -z "${PROVINCE_ID}" ] && return

    PROVINCE_NAME="${EU5_PROVINCE_NAMES[${PROVINCE_ID}]:-${PROVINCE_ID}}"
    AREA_ID="${EU5_PROVINCE_AREAS[${PROVINCE_ID}]:-}"

    if [ -n "${AREA_ID}" ]; then
        AREA_NAME="${EU5_AREA_NAMES[${AREA_ID}]:-${AREA_ID}}"
        echo " (Province: ${PROVINCE_NAME}, Area: ${AREA_NAME})"
    else
        echo " (Province: ${PROVINCE_NAME})"
    fi
}

function getEu5LocationName() {
    local LOCATION_ID="${1}"

    [[ -z "${LOCATION_ID// }" ]] && return

    loadEu5VanillaNames

    [ -n "${EU5_LOCATION_NAMES[${LOCATION_ID}]+x}" ] && echo "${EU5_LOCATION_NAMES[${LOCATION_ID}]}"
}

function getEu5ProvinceName() {
    local PROVINCE_ID="${1}"

    [[ -z "${PROVINCE_ID// }" ]] && return

    loadEu5VanillaNames

    [ -n "${EU5_PROVINCE_NAMES[${PROVINCE_ID}]+x}" ] && echo "${EU5_PROVINCE_NAMES[${PROVINCE_ID}]}"
}

function log_missing_eu5_location() {
    local GAME_ID="${1}"
    local LOCATION_TYPE="${2}"
    local LOCATION_GAME_ID="${3}"
    local LOCATION_NAME="${4}"
    local REASON="${5}"
    local CONTAINER_CONTEXT="${6}"

    echo "    > ${GAME_ID}: ${LOCATION_TYPE} ${LOCATION_GAME_ID} (${LOCATION_NAME})${CONTAINER_CONTEXT} could potentially be linked with ${REASON}"
    echo '    <GameIds>'
    echo "      <GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\">${LOCATION_GAME_ID}</GameId> <!-- ${LOCATION_NAME} -->"
    echo '    </GameIds>'
    echo ''
}

function logLinkableEu5Location() {
    local GAME_ID="${1}"
    local LOCATION_TYPE="${2}"
    local LOCATION_GAME_ID="${3}"
    local LOCATION_NAME="${4}"
    local CONTAINER_CONTEXT=''

    loadEu5LocationSets
    loadEu5VanillaNames
    loadEu5Parentage

    CONTAINER_CONTEXT=$(getEu5ContainerContext "${LOCATION_GAME_ID}" "${LOCATION_TYPE}")

    local LOCATION_ID=$(nameToLocationId "${LOCATION_NAME}")

    if [ -n "${LOCATION_ID}" ] && [ -n "${EU5_LOCATION_IDS[${LOCATION_ID}]+x}" ]; then
        log_missing_eu5_location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_GAME_ID}" "${LOCATION_NAME}" "location <Id>${LOCATION_ID}</Id>" "${CONTAINER_CONTEXT}"
    elif [ -n "${LOCATION_ID}" ] && [ -n "${EU5_UNUSED_LOCATION_IDS[${LOCATION_ID}]+x}" ]; then
        log_missing_eu5_location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_GAME_ID}" "${LOCATION_NAME}" "unused location <Id>${LOCATION_ID}</Id>" "${CONTAINER_CONTEXT}"
    elif [ -n "${EU5_LOCATION_GAMEID_COMMENTS[${LOCATION_NAME}]+x}" ]; then
        log_missing_eu5_location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_GAME_ID}" "${LOCATION_NAME}" "a location with a link with the same default name (${LOCATION_NAME})" "${CONTAINER_CONTEXT}"
    elif [ -n "${EU5_UNUSED_LOCATION_GAMEID_COMMENTS[${LOCATION_NAME}]+x}" ]; then
        log_missing_eu5_location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_GAME_ID}" "${LOCATION_NAME}" "an unused location with a link with the same default name (${LOCATION_NAME})" "${CONTAINER_CONTEXT}"
    elif [ -n "${EU5_LOCATION_NAME_VALUES[${LOCATION_NAME}]+x}" ]; then
        log_missing_eu5_location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_GAME_ID}" "${LOCATION_NAME}" "a location with a localisation with the same name (${LOCATION_NAME})" "${CONTAINER_CONTEXT}"
    elif [ -n "${EU5_UNUSED_LOCATION_NAME_VALUES[${LOCATION_NAME}]+x}" ]; then
        log_missing_eu5_location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_GAME_ID}" "${LOCATION_NAME}" "an unused location with a localisation with the same name (${LOCATION_NAME})" "${CONTAINER_CONTEXT}"
    #else
    #    log_missing_eu5_location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_GAME_ID}" "${LOCATION_NAME}" 'a new location' "${CONTAINER_CONTEXT}"
    fi
}

function list_missing_eu5_locations() {
    local GAME_ID="${1}"
    local VANILLA_FILE="${EU5_VANILLA_LOCATIONS_FILE}"
    local LOCATION_TYPE='Location'
    local LOCATION_ID=''
    local LOCATION_NAME=''

    [ ! -f "${VANILLA_FILE}" ] && return

    loadEu5VanillaNames

    for LOCATION_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) <( \
                            awk -F"=" '{print $1}' "${VANILLA_FILE}" | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        LOCATION_NAME="${EU5_LOCATION_NAMES[${LOCATION_ID}]:-}"

        [ -z "${LOCATION_NAME}" ] && continue

        logLinkableEu5Location "${GAME_ID}" "${LOCATION_TYPE}" "${LOCATION_ID}" "${LOCATION_NAME}"
    done
}

function list_surplus_eu5_locations() {
    local GAME_ID="${1}"
    local VANILLA_FILE="${EU5_VANILLA_LOCATIONS_FILE}"
    local LOCATION_TYPE='Location'

    [ ! -f "${VANILLA_FILE}" ] && return

    for LOCATION_ID in $(diff \
                        <( \
                            awk -F"=" '{print $1}' "${VANILLA_FILE}" | \
                            sort | uniq \
                        ) <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        echo "    > ${GAME_ID}: ${LOCATION_TYPE} ${LOCATION_ID} is defined but it does not exist. Find it with: ${GAME_ID}[^>]*type=\"${LOCATION_TYPE}\"[^>]*>${LOCATION_ID}<"
    done
}

function list_missing_eu5_provinces() {
    local GAME_ID="${1}"
    local VANILLA_FILE="${EU5_VANILLA_PROVINCES_FILE}"
    local LOCATION_TYPE='Province'
    local PROVINCE_ID=''
    local PROVINCE_NAME=''

    [ ! -f "${VANILLA_FILE}" ] && return

    loadEu5VanillaNames

    for PROVINCE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) <( \
                            awk -F"=" '{print $1}' "${VANILLA_FILE}" | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        PROVINCE_NAME="${EU5_PROVINCE_NAMES[${PROVINCE_ID}]:-}"

        [ -z "${PROVINCE_NAME}" ] && continue

        logLinkableEu5Location "${GAME_ID}" "${LOCATION_TYPE}" "${PROVINCE_ID}" "${PROVINCE_NAME}"
    done
}

function list_surplus_eu5_provinces() {
    local GAME_ID="${1}"
    local VANILLA_FILE="${EU5_VANILLA_PROVINCES_FILE}"
    local LOCATION_TYPE='Province'

    [ ! -f "${VANILLA_FILE}" ] && return

    for PROVINCE_ID in $(diff \
                        <( \
                            awk -F"=" '{print $1}' "${VANILLA_FILE}" | \
                            sort | uniq \
                        ) <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"${LOCATION_TYPE}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        echo "    > ${GAME_ID}: ${LOCATION_TYPE} ${PROVINCE_ID} is defined but it does not exist. Find it with: ${GAME_ID}[^>]*type=\"${LOCATION_TYPE}\"[^>]*>${PROVINCE_ID}<"
    done
}

function list_mismatching_eu5_localisations() {
    local GAME_ID="${1}"
    local LOCATION_LINE=''
    local LOCATION_ID=''
    local LOCATION_NAME_ACTUAL=''
    local LOCATION_NAME_EXPECTED=''

    loadEu5VanillaNames

    while IFS= read -r LOCATION_LINE; do
        LOCATION_ID=$(sed 's/.*>\([^<]*\)<\/GameId>.*/\1/g' <<< "${LOCATION_LINE}")
        LOCATION_NAME_ACTUAL=$(sed 's/.*<!-- \(.*\) -->.*/\1/g' <<< "${LOCATION_LINE}")
        LOCATION_NAME_EXPECTED="${EU5_LOCATION_NAMES[${LOCATION_ID}]:-}"

        [ -z "${LOCATION_NAME_EXPECTED}" ] && continue

        if [ "${LOCATION_NAME_ACTUAL}" != "${LOCATION_NAME_EXPECTED}" ]; then
            echo "Wrong default localisation for ${GAME_ID} location ${LOCATION_ID} (${LOCATION_NAME_ACTUAL}) ! Correct one is: ${LOCATION_NAME_EXPECTED} | Find it with ${GAME_ID}[^>]*type=\"Location\"[^>]*>${LOCATION_ID}<"
        fi
    done < <(grep "${GAME_ID}\" type=\"Location" "${LOCATIONS_FILE}")

    while IFS= read -r LOCATION_LINE; do
        LOCATION_ID=$(sed 's/.*>\([^<]*\)<\/GameId>.*/\1/g' <<< "${LOCATION_LINE}")
        LOCATION_NAME_ACTUAL=$(sed 's/.*<!-- \(.*\) -->.*/\1/g' <<< "${LOCATION_LINE}")
        LOCATION_NAME_EXPECTED="${EU5_PROVINCE_NAMES[${LOCATION_ID}]:-}"

        [ -z "${LOCATION_NAME_EXPECTED}" ] && continue

        if [ "${LOCATION_NAME_ACTUAL}" != "${LOCATION_NAME_EXPECTED}" ]; then
            echo "Wrong default localisation for ${GAME_ID} province ${LOCATION_ID} (${LOCATION_NAME_ACTUAL}) ! Correct one is: ${LOCATION_NAME_EXPECTED} | Find it with ${GAME_ID}[^>]*type=\"Province\"[^>]*>${LOCATION_ID}<"
        fi
    done < <(grep "${GAME_ID}\" type=\"Province" "${LOCATIONS_FILE}")
}

function list_surplus_eu5_languages() {
    local GAME_ID="${1}"
    local CULTURE_IDS=''
    local LANGUAGE_IDS=''
    local GAME_ID_VALUE=''

    [ ! -f "${EU5_VANILLA_CULTURES_FILE}" ] && return
    [ ! -f "${EU5_VANILLA_LANGUAGES_FILE}" ] && return

    CULTURE_IDS=$(awk -F"=" '{print $1}' "${EU5_VANILLA_CULTURES_FILE}")
    LANGUAGE_IDS=$(awk -F"=" '{print $1}' "${EU5_VANILLA_LANGUAGES_FILE}")

    for GAME_ID_VALUE in $(grep "GameId game=\"${GAME_ID}\"" "${LANGUAGES_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort -u); do
        grep -Fxq "${GAME_ID_VALUE}" <<< "${CULTURE_IDS}" && continue
        grep -Fxq "${GAME_ID_VALUE}" <<< "${LANGUAGE_IDS}" && continue

        echo "    > ${GAME_ID}: Language ${GAME_ID_VALUE} is linked but it does not exist in the game"
    done
}
