#!/bin/bash
source "scripts/common/paths.sh"
source "${SCRIPTS_COMMON_DIR}/utils.sh"
source "${SCRIPTS_COMMON_DIR}/name_normalisation.sh"
source "${SCRIPTS_COMMON_DIR}/hoi4.sh"
source "${SCRIPTS_COMMON_DIR}/parser.sh"

LANGUAGE_IDS=$(xmlstarlet sel -t -m "//Language" -v "Id" -n "${LANGUAGES_FILE}" | sort -u)
UNLINKED_LANGUAGE_IDS=$(xmlstarlet sel -t -m "//Language[not(GameIds/GameId)]" -v "Id" -n "${LANGUAGES_FILE}" | sort -u)
REFERENCED_LANGUAGE_IDS=$(xmlstarlet sel -t -m "//Name" -v "@language" -n "${LOCATIONS_FILE}" | sort -u)
FALLBACK_LANGUAGE_IDS=$(xmlstarlet sel -t -m "//Language/FallbackLanguages/LanguageId" -v "." -n "${LANGUAGES_FILE}" | sort -u)

LOCATION_IDS=$(xmlstarlet sel -t -m "//LocationEntity" -v "Id" -n "${LOCATIONS_FILE}" | sort -u)
UNLINKED_LOCATION_IDS=$(xmlstarlet sel -t -m "//LocationEntity[not(GameIds/GameId)]" -v "Id" -n "${LOCATIONS_FILE}" | sort -u)
UNUSED_LOCATION_IDS=$(xmlstarlet sel -t -m "//LocationEntity" -v "Id" -n "${UNUSED_LOCATIONS_FILE}" | sort -u)
FALLBACK_LOCATION_IDS=$(xmlstarlet sel -t -m "//FallbackLocations/LocationId" -v "." -n "${LOCATIONS_FILE}" | sort -u)

LANGUAGES_FILE_CONTENT=$(cat "${LANGUAGES_FILE}")

GAME_IDS_CK="$(xmlstarlet sel -t -m "//GameId[starts-with(@game, 'CK')]" -v "." -n "${LOCATIONS_FILE}" | sort -u)"
NAME_VALUES="$(xmlstarlet sel -t -m "//Name" -v "@value" -n "${LOCATIONS_FILE}" | sort -u)"
DEFAULT_NAME_VALUES="$(grep "<GameId game=" "${LOCATIONS_FILE}" | sed 's/.*<\!-- \(.*\) -->$/\1/g' | sort -u)"

function getGameIds() {
    local GAME="${1}"

    grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
        sed 's/[^>]*>\([^<]*\).*/\1/g' | \
        sort
}

function checkForSurplusCk3LanguageLinks() {
    local GAME="${1}" && shift

    for CULTURE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME}\"" "${LANGUAGES_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort -u \
                        ) <( \
                            find "${@}" -maxdepth 1 -name "*.txt" -exec cat {} + | \
                            grep -P '^\s*name_list\s*=' | \
                            awk -F"=" '{print $2}' | \
                            sed 's/\s//g' | \
                            sed 's/#.*//g' | \
                            sed 's/^name_list_//g' | \
                            sort -u \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME}: ${CULTURE_ID} culture is defined but it does not exist"
    done
}

function checkForMismatchingLanguageLinks() {
    local GAME="${1}" && shift
    local NO_DIRECTORY_EXISTS=true

    for CULTURES_DIR in "${@}"; do
        [ -f "${CULTURES_DIR}" ] && NO_DIRECTORY_EXISTS=false
        break
    done

    ${NO_DIRECTORY_EXISTS} && return

    [ -n "${3}" ] && INHERITS_FROM_VANILLA=${3}

    if [[ ${GAME} == CK3* ]]; then
        checkForSurplusCk3LanguageLinks "${GAME}" "${@}"
    fi
}

function checkForMissingCkLocationLinks() {
    local GAME_ID="${1}" && shift
    local VANILLA_LANDED_TITLES="${1}" && shift

    for LANDED_TITLE_ID in $(diff \
                        <(getGameIds "${GAME_ID}") \
                        <( \
                            cat "${VANILLA_LANDED_TITLES}" | \
                            if file "${VANILLA_LANDED_TITLES}" | grep -q 'Non-ISO\|ISO-8859'; then
                                iconv -f WINDOWS-1252 -t UTF-8 2> /dev/null
                            else
                                cat
                            fi | \
                            grep -i "^\s*[ekdcb]_.*=" | \
                            awk -F"=" '{print $1}' | \
                            sed 's/[^a-zA-Z0-9_\-]//g' | \
                            sort -u \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do

        [[ ${LANDED_TITLE_ID} =~ _color$ ]] && continue

        LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LANDED_TITLE_ID}")
        [ -n "${1}" ] && LOCATION_DEFAULT_NAME=$(tac "${@}" | grep "^ *${LANDED_TITLE_ID}:" | head -n 1 | sed 's/^ *\([^:]*\):[0-9]* *\"\([^\"]*\).*/\2/g')

        if $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
        elif $(echo "${UNUSED_LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but unused location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
        elif $(echo "${GAME_IDS_CK}" | sed -e 's/^..//g' -e 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
        elif [ -n "${LOCATION_DEFAULT_NAME}" ]; then
            LOCATION_ID=$(nameToLocationId "${LOCATION_DEFAULT_NAME}")
            LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

            if $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
                echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            elif $(echo "${UNUSED_LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
                echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but unused location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            elif $(echo "${GAME_IDS_CK}" | sed -e 's/^..//g' -e 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
                echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            elif $(echo "${NAME_VALUES}" | grep -Eioq "^${LOCATION_DEFAULT_NAME}$"); then
                echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but a location with the \"${LOCATION_DEFAULT_NAME}\" name exists)"
            elif $(echo "${DEFAULT_NAME_VALUES}" | grep -Eioq "^${LOCATION_DEFAULT_NAME}$"); then
                echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but a location with the \"${LOCATION_DEFAULT_NAME}\" default name exists)"
            else
                echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} (${LOCATION_DEFAULT_NAME}) is missing"
            fi
        else
            echo "    > 2 ${GAME_ID}: ${LANDED_TITLE_ID} is missing"
        fi
    done
}

function checkForSurplusCkLocationLinks() {
    local GAME_ID="${1}"
    local VANILLA_LANDED_TITLES="${2}"

    for LANDED_TITLE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort -u \
                        ) <( \
                            cat "${VANILLA_LANDED_TITLES}" | \
                            if file "${VANILLA_LANDED_TITLES}" | grep -q 'Non-ISO\|ISO-8859'; then
                                iconv -f WINDOWS-1252 -t UTF-8 2> /dev/null
                            else
                                cat
                            fi | \
                            grep -i "^\s*[ekdcb]_.*=" | \
                            awk -F"=" '{print $1}' | \
                            sed 's/[^a-zA-Z0-9_\-]//g' | \
                            sort -u \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME_ID}: ${LANDED_TITLE_ID} is defined but it does not exist"
    done
}

function checkForMissingIrLocationLinks() {
    local GAME_ID="${1}" && shift
    local VANILLA_LOCALISATION_FILE="${1}" && shift

    for PROVINCE_ID in $(diff \
                        <(getGameIds "${GAME_ID}") \
                        <( \
                            cat "${VANILLA_LOCALISATION_FILE}" | \
                            grep "^\s*PROV[0-9][0-9]*:" | \
                            awk -F':' '{print $1}' | \
                            sed 's/^\s*PROV//g' | \
                            sort -u \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        LOCATION_DEFAULT_NAME=$(getVanillaIrLocationName "${VANILLA_LOCALISATION_FILE}" "${PROVINCE_ID}")
        LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_NAME}")

        if $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
        elif $(echo "${UNUSED_LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but unused location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
        elif $(echo "${GAME_IDS_CK}" | sed -e 's/^..//g' -e 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
        elif [ -n "${LOCATION_DEFAULT_NAME}" ]; then
            LOCATION_ID=$(nameToLocationId "${LOCATION_DEFAULT_NAME}")
            LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

            if $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
                echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            elif $(echo "${UNUSED_LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
                echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but unused location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            elif $(echo "${GAME_IDS_CK}" | sed -e 's/^..//g' -e 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
                echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            elif $(echo "${NAME_VALUES}" | grep -Eioq "^${LOCATION_DEFAULT_NAME}$"); then
                echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but a location with the \"${LOCATION_DEFAULT_NAME}\" name exists)"
            elif $(echo "${DEFAULT_NAME_VALUES}" | grep -Eioq "^${LOCATION_DEFAULT_NAME}$"); then
                echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but a location with the \"${LOCATION_DEFAULT_NAME}\" default name exists)"
            else
                echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing"
            fi
        else
            echo "    > ${GAME_ID}: ${PROVINCE_ID} (${LOCATION_DEFAULT_NAME}) is missing"
        fi
    done
}

function checkForSurplusIrLocationLinks() {
    local GAME_ID="${1}"
    local VANILLA_FILE="${2}"

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
        echo "    > ${GAME_ID}: ${PROVINCE_ID} is defined but it does not exist"
    done
}

function checkForMissingVic3LanguageLinks() {
    local GAME_ID="${1}"
    local VANILLA_COUNTRIES_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_countries.txt"

    for COUNTRY_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LANGUAGES_FILE}" |
                            sed 's/.*>\([^<]*\)<\/GameId.*/\1/g' |
                            sort | uniq \
                        ) <( \
                            cat "${VANILLA_COUNTRIES_FILE}" | \
                            awk -F"=" '{print $1}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        LOCATION_DEFAULT_NAME=$(grep "^${COUNTRY_ID}=" "${VANILLA_COUNTRIES_FILE}" | awk -F"=" '{print $2}')
        LOCATION_ID=$(nameToLocationId "${LOCATION_DEFAULT_NAME}")
        LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

        if grep -q "<!-- ${LOCATION_DEFAULT_NAME} -->" "${LANGUAGES_FILE}"; then
            echo "    > ${GAME_ID}: Language ${COUNTRY_ID} (${LOCATION_DEFAULT_NAME}) is missing (but another GameId \"${LOCATION_DEFAULT_NAME}\" exists)"
            echo "      <GameId game=\"Vic3\">${COUNTRY_ID}</GameId> <!-- ${LOCATION_DEFAULT_NAME} -->"
        else
            echo "    > ${GAME_ID}: Language ${COUNTRY_ID} (${LOCATION_DEFAULT_NAME}) is missing"
            echo "      <GameId game=\"Vic3\">${COUNTRY_ID}</GameId> <!-- ${LOCATION_DEFAULT_NAME} -->"
        fi
    done
}

function checkForMissingVic3CountryLinks() {
    local GAME_ID="${1}"
    local VANILLA_COUNTRIES_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_countries.txt"

    for COUNTRY_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"Country\"" "${LOCATIONS_FILE}" |
                            sed 's/.*>\([^<]*\)<\/GameId.*/\1/g' |
                            sort | uniq \
                        ) <( \
                            cat "${VANILLA_COUNTRIES_FILE}" | \
                            awk -F"=" '{print $1}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        LOCATION_DEFAULT_NAME=$(grep "^${COUNTRY_ID}=" "${VANILLA_COUNTRIES_FILE}" | awk -F"=" '{print $2}')
        LOCATION_ID=$(nameToLocationId "${LOCATION_DEFAULT_NAME}")
        LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

        if $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: Country ${COUNTRY_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            echo "      <GameId game=\"Vic3\" type=\"Country\">${COUNTRY_ID}</GameId> <!-- ${LOCATION_DEFAULT_NAME} -->"
        elif $(echo "${NAME_VALUES}" | grep -Eioq "^${LOCATION_DEFAULT_NAME}$"); then
            echo "    > ${GAME_ID}: Country ${COUNTRY_ID} (${LOCATION_DEFAULT_NAME}) is missing (but a location with the \"${LOCATION_DEFAULT_NAME}\" name exists)"
            echo "      <GameId game=\"Vic3\" type=\"Country\">${COUNTRY_ID}</GameId> <!-- ${LOCATION_DEFAULT_NAME} -->"
        else
            echo "    > ${GAME_ID}: Country ${COUNTRY_ID} (${LOCATION_DEFAULT_NAME}) is missing"
        fi
    done
}

function checkForMissingVic3StateLinks() {
    local GAME_ID="${1}"
    local VANILLA_STATES_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_states.txt"

    for STATE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"State\"" "${LOCATIONS_FILE}" |
                            sed 's/.*>\([^<]*\)<\/GameId.*/\1/g' |
                            sort | uniq \
                        ) <( \
                            cat "${VANILLA_STATES_FILE}" | \
                            awk -F"=" '{print $1}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        LOCATION_DEFAULT_NAME=$(grep "^${STATE_ID}=" "${VANILLA_STATES_FILE}" | awk -F"=" '{print $2}')
        LOCATION_ID=$(nameToLocationId "${LOCATION_DEFAULT_NAME}")
        LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

        if $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: State ${STATE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            echo "      <GameId game=\"Vic3\" type=\"State\">${STATE_ID}</GameId> <!-- ${LOCATION_DEFAULT_NAME} -->"
        elif $(echo "${NAME_VALUES}" | grep -Eioq "^${LOCATION_DEFAULT_NAME}$"); then
            echo "    > ${GAME_ID}: State ${STATE_ID} (${LOCATION_DEFAULT_NAME}) is missing (but a location with the \"${LOCATION_DEFAULT_NAME}\" name exists)"
            echo "      <GameId game=\"Vic3\" type=\"State\">${STATE_ID}</GameId> <!-- ${LOCATION_DEFAULT_NAME} -->"
        else
            echo "    > ${GAME_ID}: State ${STATE_ID} (${LOCATION_DEFAULT_NAME}) is missing"
        fi
    done
}

function checkForMissingVic3HubLinks() {
    local GAME_ID="${1}"
    local VANILLA_HUBS_FILE="${VANILLA_FILES_DIR}/${GAME_ID}_hubs.txt"

    for HUB_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\" type=\"Hub\"" "${LOCATIONS_FILE}" |
                            sed 's/.*>\([^<]*\)<\/GameId.*/\1/g' |
                            sort | uniq \
                        ) <( \
                            cat "${VANILLA_HUBS_FILE}" | \
                            awk -F"=" '{print $1}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        LOCATION_DEFAULT_NAME=$(grep "^${HUB_ID}=" "${VANILLA_HUBS_FILE}" | awk -F"=" '{print $2}')
        LOCATION_ID=$(nameToLocationId "${LOCATION_DEFAULT_NAME}")
        LOCATION_ID_FOR_SEARCH=$(locationIdToSearcheableId "${LOCATION_ID}")

        if $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME_ID}: Hub ${HUB_ID} (${LOCATION_DEFAULT_NAME}) is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
            echo "      <GameId game=\"Vic3\" type=\"Hub\">${HUB_ID}</GameId> <!-- ${LOCATION_DEFAULT_NAME} -->"
        elif $(echo "${NAME_VALUES}" | grep -Eioq "^${LOCATION_DEFAULT_NAME}$"); then
            echo "    > ${GAME_ID}: Hub ${HUB_ID} (${LOCATION_DEFAULT_NAME}) is missing (but a location with the \"${LOCATION_DEFAULT_NAME}\" name exists)"
            echo "      <GameId game=\"Vic3\" type=\"Hub\">${HUB_ID}</GameId> <!-- ${LOCATION_DEFAULT_NAME} -->"
        else
            echo "    > ${GAME_ID}: Hub ${HUB_ID} (${LOCATION_DEFAULT_NAME}) is missing"
        fi
    done
}

function checkForMismatchingLanguageLinks() {
    local GAME_ID="${1}" && shift

    if [[ ${GAME_ID} == Vic3* ]]; then
        checkForMissingVic3LanguageLinks "${GAME_ID}"
    fi
}

function checkForMismatchingLocationLinks() {
    local GAME_ID="${1}" && shift
    local VANILLA_FILE="${1}" && shift

    [[ ${GAME_ID} != HOI4* ]] && [[ ${GAME_ID} != Vic3* ]] && [ ! -f "${VANILLA_FILE}" ] && return

    if [[ ${GAME_ID} == CK* ]]; then
        checkForMissingCkLocationLinks "${GAME_ID}" "${VANILLA_FILE}" "${@}"
        checkForSurplusCkLocationLinks "${GAME_ID}" "${VANILLA_FILE}"
    elif [[ ${GAME_ID} == HOI4* ]]; then
        #checkForMissingHoi4LocationLinks "${GAME_ID}"
        checkForSurplusHoi4LocationLinks "${GAME_ID}"
        validateHoi4Parentage "${GAME_ID}"
    elif [[ ${GAME_ID} == IR* ]]; then
        #checkForMissingIrLocationLinks "${GAME_ID}" "${VANILLA_FILE}"
        checkForSurplusIrLocationLinks "${GAME_ID}" "${VANILLA_FILE}"
    elif [[ ${GAME_ID} == Vic3* ]]; then
        checkForMissingVic3CountryLinks "${GAME_ID}"
        checkForMissingVic3StateLinks "${GAME_ID}"
        checkForMissingVic3HubLinks "${GAME_ID}"
    fi
}

function checkForMismatchingLinks() {
    local GAME_ID="${1}" && shift
    local VANILLA_FILE="${1}" && shift

    checkForMismatchingLanguageLinks "${GAME_ID}"
    checkForMismatchingLocationLinks "${GAME_ID}" "${VANILLA_FILE}"
}

function checkDefaultCk2Localisations() {
    local GAME_ID="${1}" && shift

    [ ! -f "${1}" ] && return

    for GAMEID_DEFINITION in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/ defaultLanguage=\"[^\"]*\"//g' | \
                            sed 's/^ *//g' |
                            sort
                        ) <( \
                            awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                                <(getGameIds "${GAME_ID}") \
                                <( \
                                    tac "${@}" | \
                                    grep -a "^[ekdb]_" | \
                                    grep -a -v ".*_adj_.*" | \
                                    awk -F";" '!seen[$1]++' | \
                                    awk -F";" '{print $1"="$2}' | \
                                    sed -e 's/\s*=\s*/=/g' -e 's/ *$//g' | \
                                    iconv -f WINDOWS-1252 -t UTF-8 2> /dev/null
                                ) | \
                            awk -F"=" '{print "<GameId game=\"'${GAME_ID}'\">"$1"</GameId> <!-- "$2" -->"}' | \
                            sort -u \
                        ) | \
                        grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
        echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
    done
}

function checkDefaultCk3Localisations() {
    local GAME_ID="${1}" && shift

    [ ! -f "${1}" ] && return

    for GAMEID_DEFINITION in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/ defaultLanguage=\"[^\"]*\"//g' | \
                            sed 's/^ *//g' |
                            sort
                        ) <( \
                            awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                                <(getGameIds "${GAME_ID}") \
                                <( \
                                    tac "${@}" | \
                                    grep -a "^ *[ekdcb]_" | \
                                    grep -v "_adj:" | \
                                    sed 's/^ *\([^:]*\):[0-9]* *\"\([^\"]*\).*/\1=\2/g' | \
                                    awk -F"=" '!seen[$1]++' | \
                                    sed -e 's/= */=/g' -e 's/ *$//g'
                                ) | \
                            awk -F"=" '{print "<GameId game=\"'${GAME_ID}'\">"$1"</GameId> <!-- "$2" -->"}' | \
                            sort -u \
                        ) | \
                        grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
        echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
    done
}

function checkDefaultHoi4Localisations() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"

    [ ! -d "${LOCALISATIONS_DIR}" ] && return

    while IFS= read -r CITY_LINE; do
        CITY_ID=$(sed 's/.*>\([0-9][0-9]*\)<\/GameId>.*/\1/g' <<< "${CITY_LINE}")

        local CITY_NAME_EXPECTED=$(getHoi4CityName "${CITY_ID}" "${LOCALISATIONS_DIR}")

        if [ -n "${CITY_NAME_EXPECTED}" ]; then
            local CITY_NAME_ACTUAL=$(sed 's/.*<!-- \(.*\) -->.*/\1/g' <<< "${CITY_LINE}")

            if [ "${CITY_NAME_ACTUAL}" != "${CITY_NAME_EXPECTED}" ]; then
                echo "Wrong default localisation for ${GAME_ID} city ${CITY_ID} ! Correct one is: ${CITY_NAME_EXPECTED} | Find it with ${GAME_ID}[^A-Z].*City.*>${CITY_ID}<"
            fi
        fi
    done < <(grep "${GAME_ID}\" type=\"City" "${LOCATIONS_FILE}")

    while IFS= read -r STATE_LINE; do
        STATE_ID=$(sed 's/.*>\([0-9][0-9]*\)<\/GameId>.*/\1/g' <<< "${STATE_LINE}")

        local STATE_NAME_EXPECTED=$(getHoi4StateName "${STATE_ID}" "${LOCALISATIONS_DIR}")

        if [ -n "${STATE_NAME_EXPECTED}" ]; then
            local STATE_NAME_ACTUAL=$(sed 's/.*<!-- \(.*\) -->.*/\1/g' <<< "${STATE_LINE}")

            if [ "${STATE_NAME_ACTUAL}" != "${STATE_NAME_EXPECTED}" ]; then
                echo "Wrong default localisation for ${GAME_ID} state ${STATE_ID} ! Correct one is: ${STATE_NAME_EXPECTED} | Find it with ${GAME_ID}[^A-Z].*State.*>${STATE_ID}<"
            fi
        fi
    done < <(grep "${GAME_ID}\" type=\"State" "${LOCATIONS_FILE}")
}

function checkDefaultIrLocalisations() {
    local GAME_ID="${1}" && shift

    [ ! -f "${1}" ] && return

    for GAMEID_DEFINITION in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/ defaultLanguage=\"[^\"]*\"//g' | \
                            sed 's/^ *//g' |
                            sort
                        ) <( \
                            awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                                <(getGameIds "${GAME_ID}") \
                                <( \
                                    tac "${@}" | \
                                    grep "^\s*PROV" | \
                                    grep -v "_[A-Za-z_-]*:" | \
                                    awk '!x[substr($0,0,index($0, ":"))]++' | \
                                    sed 's/^\s*PROV\([0-9]*\):[0-9]*\s*\"\([^\"]*\).*/\1=\2/g' | \
                                    sed -e 's/=\s*/=/g' -e 's/\s*$//g'
                                ) | \
                            awk -F"=" '{print "<GameId game=\"'${GAME_ID}'\">"$1"</GameId> <!-- "$2" -->"}' | \
                            sort -u \
                        ) | \
                        grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
        echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
    done
}

function checkDefaultVic3Localisations() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"

    [ ! -d "${LOCALISATIONS_DIR}" ] && return

    while IFS= read -r HUB_LINE; do
        HUB_ID=$(sed 's/.*>\(STATE_[A-Z][A-Z_]*_[a-z][a-z]*\)<\/GameId>.*/\1/g' <<< "${HUB_LINE}")

        local HUB_NAME_EXPECTED=$(getVanillaVic3HubName "${HUB_ID}" "${LOCALISATIONS_DIR}")

        if [ -n "${HUB_NAME_EXPECTED}" ]; then
            local HUB_NAME_ACTUAL=$(sed 's/.*<!-- \(.*\) -->.*/\1/g' <<< "${HUB_LINE}")

            if [ "${HUB_NAME_ACTUAL}" != "${HUB_NAME_EXPECTED}" ]; then
                echo "Wrong default localisation for ${GAME_ID} hub ${HUB_ID} (${HUB_NAME_ACTUAL}) ! Correct one is: ${HUB_NAME_EXPECTED}"
            fi
        fi
    done < <(grep "${GAME_ID}\" type=\"Hub" "${LOCATIONS_FILE}")
}

function validateHoi4Parentage() {
    local GAME_ID="${1}"
    local VANILLA_FILE=$(get_variable "${GAME_ID}_VANILLA_PARENTAGE_FILE")
    local LOCALISATIONS_DIR=$(get_variable "${GAME_ID}_LOCALISATIONS_DIR")

    while IFS= read -r CITY_LINE; do
        CITY_ID=$(sed 's/.*>\([0-9][0-9]*\)<\/GameId>.*/\1/g' <<< "${CITY_LINE}")
        ACTUAL_STATE_ID=$(sed 's/.*parent=\"\([^\"]*\).*/\1/g' <<< "${CITY_LINE}")
        EXPECTED_STATE_ID=$(grep "^${CITY_ID}=" "${VANILLA_FILE}" | head -n 1 | awk -F'=' '{print $2}')

        if [ "${ACTUAL_STATE_ID}" != "${EXPECTED_STATE_ID}" ]; then
            local CITY_NAME=$(getHoi4CityName "${CITY_ID}" "${LOCALISATIONS_DIR}")
            local STATE_NAME=$(getHoi4StateName "${EXPECTED_STATE_ID}" "${LOCALISATIONS_DIR}")

            echo "${GAME_ID}: City ${CITY_ID} (${CITY_NAME}) is not linked to the correct state. Correct parent: ${EXPECTED_STATE_ID} (${STATE_NAME})"
        fi
    done < <(grep "${GAME_ID}\" type=\"City" "${LOCATIONS_FILE}")
}

function findRedundantNames() {
    local PRIMARY_LANGUAGE_ID="${1}" && shift
    return # TODO: Rethink this because of fallbacks and time periods

    for SECONDARY_LANGUAGE_ID in "${@}"; do
        for LOCATION_ID in $(xmlstarlet \
                                    sel -t -m \
                                    "//LocationEntity[
                                        Names/Name[@language='${PRIMARY_LANGUAGE_ID}']/@value = Names/Name[@language='${SECONDARY_LANGUAGE_ID}']/@value
                                        and (not(Names/Name[@language='${PRIMARY_LANGUAGE_ID}']/@comment) and not(Names/Name[@language='${SECONDARY_LANGUAGE_ID}']/@comment))
                                        or (Names/Name[@language='${PRIMARY_LANGUAGE_ID}']/@comment = Names/Name[@language='${SECONDARY_LANGUAGE_ID}']/@comment)
                                    ]" \
                                    -v "Id" -n "${LOCATIONS_FILE}"); do
            echo "Redundant name for location '${LOCATION_ID}': ${SECONDARY_LANGUAGE_ID}"
        done
    done
}

function validateThatTheLanguagesAreOrdered() {
    local LANGUAGES_FILE_TO_CHECK="${1}"
    local ACTUAL_LANGUAGES_LIST=""
    local EXPECTED_LANGUAGES_LIST=""

    ACTUAL_LANGUAGES_LIST=$(xmlstarlet sel -t -m "//Id" -v "." -n "${LANGUAGES_FILE_TO_CHECK}" | \
                            grep -v '_\(Ancient\|Archaic\|Before\|Classical\|Early\|Late\|Medieval\|Middle\|Old\|Proto\)')
    EXPECTED_LANGUAGES_LIST=$(sort <<< ${ACTUAL_LANGUAGES_LIST})

    diff --context=1 --color --suppress-common-lines <(echo "${ACTUAL_LANGUAGES_LIST}" | sed 's/%NL%/\n/g') <(echo "${EXPECTED_LANGUAGES_LIST}" | sed 's/%NL%/\n/g')
}

function validateThatTheLocationsAreOrdered() {
    local LOCATIONS_FILE_TO_CHECK="${1}"
    local ACTUAL_LOCATIONS_LIST=""
    local EXPECTED_LOCATIONS_LIST=""

    ACTUAL_LOCATIONS_LIST=$(head "${LOCATIONS_FILE_TO_CHECK}" -n "${WELL_COVERED_SECTION_END_LINE_NR}" | \
                            grep -a "<Id>" && \
                            tail -n +"${WELL_COVERED_SECTION_END_LINE_NR}" "${LOCATIONS_FILE_TO_CHECK}" | grep "Id>$" | \
                            grep -Pzo "\n\s*<Id>[^<]*</Id>*\n\s*<(GeoNamesId|Pleiades|Wikidata)" | \
                            grep -av "^\s*$" | \
                            grep -a "<Id>")
    ACTUAL_LOCATIONS_LIST=$(grep -a "<Id>" <<< "${ACTUAL_LOCATIONS_LIST}" | \
                            sed 's/^\s*<Id>\([^<]*\).*/\1/g' | \
                            sed -r '/^\s*$/d' | \
                            perl -p0e 's/\r*\n/%NL%/g')
    EXPECTED_LOCATIONS_LIST=$(echo "${ACTUAL_LOCATIONS_LIST}" | \
                                sed 's/%NL%/\n/g' | \
                                sort | \
                                sed -r '/^\s*$/d' | \
                                perl -p0e 's/\r*\n/%NL%/g')

    diff --context=1 --color --suppress-common-lines <(echo "${ACTUAL_LOCATIONS_LIST}" | sed 's/%NL%/\n/g') <(echo "${EXPECTED_LOCATIONS_LIST}" | sed 's/%NL%/\n/g')
}

### Make sure locations are sorted alphabetically

OLD_LC_COLLATE=${LC_COLLATE}
export LC_COLLATE=C
WELL_COVERED_SECTION_END_LINE_NR=$(grep -n "@@@@ BELOW TITLES NEED REVIEW" "${LOCATIONS_FILE}" | awk -F":" '{print $1}')

validateThatTheLocationsAreOrdered "${LOCATIONS_FILE}"
validateThatTheLocationsAreOrdered "${UNUSED_LOCATIONS_FILE}"

validateThatTheLanguagesAreOrdered "${LANGUAGES_FILE}"
validateThatTheLanguagesAreOrdered "${UNUSED_LANGUAGES_FILE}"

diff --context=1 --color --suppress-common-lines <(echo "${ACTUAL_LANGUAGES_LIST}" | sed 's/%NL%/\n/g') <(echo "${EXPECTED_LANGUAGES_LIST}" | sed 's/%NL%/\n/g')
export LC_COLLATE=${OLD_LC_COLLATE}

for LANGUAGE_ID in $(comm -23 <(echo "${UNLINKED_LANGUAGE_IDS}") <(echo "${REFERENCED_LANGUAGE_IDS}") | grep -vf <(echo "${FALLBACK_LANGUAGE_IDS}")); do
    echo "Unused language: ${LANGUAGE_ID} -> Delete or move it to '${UNUSED_LANGUAGES_FILE}'"
done

for LOCATION_ID in $(comm -23 <(echo "${UNLINKED_LOCATION_IDS}" | tr ' ' '\n' | sort) <(echo "${FALLBACK_LOCATION_IDS}" | tr ' ' '\n' | sort) | tr '\n' ' '); do
    echo "Unused location: ${LOCATION_ID} -> Delete or move it to '${UNUSED_LOCATIONS_FILE}'"
done

# Find missing / on node ending on the same line
grep "^\s*<[^>]*>[^<]*<[^/!]" *.xml

function checkForDuplicateEntries() {
    local XML_FILE="${1}"
    local ENTITY_FIELD="${2}"

    for DUPLICATE_ENTRY in $(xmlstarlet sel -t -m '//*['"${ENTITY_FIELD}"']' -v "${ENTITY_FIELD}" -n "${XML_FILE}" | sort | uniq -d); do
        echo "Duplicated ${ENTITY_FIELD} in '${XML_FILE}': ${DUPLICATE_ENTRY}"
    done
}

for LANGUAGES_XML in "${LANGUAGES_FILE}" "${UNUSED_LANGUAGES_FILE}"; do
    checkForDuplicateEntries "${LANGUAGES_XML}" 'Id'
done

for LOCATIONS_XML in "${LOCATIONS_FILE}" "${UNUSED_LOCATIONS_FILE}"; do
    checkForDuplicateEntries "${LOCATIONS_XML}" 'Id'
    checkForDuplicateEntries "${LOCATIONS_XML}" 'GeoNamesId'
    checkForDuplicateEntries "${LOCATIONS_XML}" 'PleiadesId'
    checkForDuplicateEntries "${LOCATIONS_XML}" 'WikidataId'
done

# Find duplicate used-unused IDs
cat "${LANGUAGES_FILE}" "${UNUSED_LANGUAGES_FILE}" | \
    grep "<Id>" | \
    sed 's/^\s*<Id>\(.*\)<\/Id>.*/\1/g' | \
    sort | uniq -c | \
    grep "^\s*[2-9]"
cat "${LOCATIONS_FILE}" "${UNUSED_LOCATIONS_FILE}" | \
    grep "<Id>" | \
    sed 's/^\s*<Id>\(.*\)<\/Id>.*/\1/g' | \
    sort | uniq -c | \
    grep "^\s*[2-9]"

# Find duplicated game IDs
grep "<GameId game=" *.xml | \
    sed -e 's/[ \t]*<!--.*-->.*//g' -e 's/^[ \t]*//g' | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find duplicated names
grep -Pzo "\n *<Name language=\"([^\"]*)\" value=\"([^\"]*)\" />((\n *<Name l.*)*)\n *<Name language=\"\1\" value=\"\2\" />.*\n" *.xml

# Find empty definitions
grep "><" "${LOCATIONS_FILE}" "${LANGUAGES_FILE}"

# Find duplicated language codes
for I in {1..3}; do
    grep "iso-639-" "${LANGUAGES_FILE}" | \
        sed -e 's/^ *<Code \(.*\) \/>.*/\1/g' \
            -e 's/ /\n/g' \
            -e 's/\"//g' | \
        grep "iso-639-${I}" | \
        awk -F"=" '{print $2}' | \
        sort | uniq -c | grep "^ *[2-9]"
done

# Validate XML structure
grep -Pzo "\n *<[a-zA-Z]*Entity>\n *<Id>.*\n *</[a-zA-Z]*Entity>.*\n" *.xml
grep -Pzo "\n *</Names.*\n *<*(Names|GameId|Location).*\n" *.xml
grep -Pzo "\n *</Names.*\n *</*(Names|GameId).*\n" *.xml
grep -Pzo "\n *<Names>\n *<[^N].*\n" *.xml
grep -Pzo "\n *<Name .*\n *</L.*\n" *.xml
grep -Pzo "\n *</GameIds>\n *<(GameId|Name ).*\n" *.xml
grep -Pzo "\n *<GameId .*\n *<Name.*\n" *.xml
grep -Pzo "\n *<(/*)GameIds.*\n *<\1GameIds.*\n" *.xml
grep -Pzo "\n *<GameIds>\n *<[^G].*\n" *.xml
grep -Pzo "\n\s*<Language>\n\s*<[^I][^d].*\n" *.xml # Missing Id (right after definition)
grep -n "^\s*</[^>]*>\s*[a-zA-Z0-9\s]" *.xml # Text after ending tags
grep -Pzo "\n\s*<(/[^>]*)>.*\n\s*<\1>\n" *.xml # Double tags
grep -Pzo "\n\s*<([^>]*)>\s*\n\s*</\1>\n" *.xml # Empty tags
grep -Pzo "\n\s*<Name .*\n\s*</GameId.*\n" *.xml # </GameId.* after <Name>
grep -Pzo "\n\s*.*</[^<]*\n\s*<Name .*\n" *.xml # <Name> after closing tags
grep -Pzo "</[a-zA-Z]*>\n\s*<Id>.*\n" *.xml # <Id> after a closing tag
grep -Pzo "<Fallback(Languages|Locations)>.*\n\s*<GameId.*\n" *.xml # <GameId.* after <FallbackLanguages> or <FallbackLocations>
grep -Pzo "</(Id|GeoNamesId|PleiadesId|WikidataId)>.*\n\s*<GameId .*\n" *.xml # <GameId .* after </Id> or </GeoNamesId> or </PleiadesId> or </WikidataId>
grep -Pzo "</(Id|GeoNamesId|PleiadesId|WikidataId)>.*\n\s*</GameId.*\n" *.xml # </GameId.* after </Id> or </GeoNamesId> or </PleiadesId> or </WikidataId>
grep -Pzo "\s*([^=\s]*)\s*=\s*\"[^\"]*\"\s*\1\s*=\"[^\"]*\".*\n" *.xml # Double attributes
grep -Pzo "\n.*=\s*\"\s*\".*\n" *.xml # Empty attributes
grep -n "^\s*<\([^> ]*\).*</.*" *.xml | grep -v "^[a-z0-9:.]*\s*<\([^> ]*\).*</\1>.*" # Mismatching start/end tag on same line
grep -Pzo "\n *</(Fallback).*\n *<(Language|Location|Title).*\n" *.xml
grep -Pzo "\n *</(Language|Location|Title)>.*\n *<Fallback.*\n" *.xml
grep -Pzo "\n *</(GameIds)>.*\n *<LanguageId.*\n" *.xml
grep -Pzo "\n *</[A-Za-z]*Entity.*\n *<(Id|Name).*\n" *.xml
grep -n "\(adjective\|value\)=\"\([^\"]*\)\"\s*>" *.xml
grep -n "<<\|>>" *.xml
grep -n "[^=]\"[a-zA-Z]*=" *.xml
grep -n "==\"" *.xml
grep --color -n "[a-zA-Z0-9]\"[^ <>/?]" *.xml
grep --color -n "/>\s*[a-z]" *.xml

grep -n "\(iso-639-[0-9]\)=\"[a-z]*\" \1" "${LANGUAGES_FILE}"
grep -Pzo "\n *<Code.*\n *<Language>.*\n" "${LANGUAGES_FILE}"

grep -Pzo "\n *<LocationEntity.*\n *<[^I].*\n" "${LOCATIONS_FILE}"

for LANGUAGE_ID in $(comm -13 <(echo "${LANGUAGE_IDS}") <(echo "${FALLBACK_LANGUAGE_IDS}")); do
    echo "Inexistent fallback language: ${LANGUAGE_ID}"
done

for LOCATION_ID in $(comm -13 <(echo "${LOCATION_IDS}") <(echo "${FALLBACK_LOCATION_IDS}")); do
    echo "Inexistent fallback location: ${LOCATION_ID}"
done

for LANGUAGE_ID in $(comm -13 <(echo "${LANGUAGE_IDS}") <(echo "${REFERENCED_LANGUAGE_IDS}")); do
    echo "Inexistent name language: ${LANGUAGE_ID}"
done

# Find multiple name definitions for the same language
grep -Pzo "\n.* language=\"([^\"]*)\".*\n.*language=\"\1\".*\n" *.xml

# Make sure all locations are defined and exist in the game
checkForMismatchingLocationLinks "CK2"      "${CK2_VANILLA_LANDED_TITLES_FILE}"     "${CK2_LOCALISATIONS_DIR}"/*.csv
checkForMismatchingLocationLinks "CK2HIP"   "${CK2HIP_VANILLA_LANDED_TITLES_FILE}"  "${CK2HIP_LOCALISATIONS_DIR}"/*.csv
checkForMismatchingLocationLinks "CK2RoI"   "${CK2RoI_VANILLA_LANDED_TITLES_FILE}"  "${CK2RoI_LOCALISATIONS_DIR}"/*.csv
#checkForMismatchingLocationLinks "CK2TWK"   "${CK2TWK_VANILLA_LANDED_TITLES_FILE}"  "${CK2TWK_LOCALISATIONS_DIR}"/*.csv
checkForMismatchingLocationLinks "CK3"      "${CK3_VANILLA_LANDED_TITLES_FILE}"     "${CK3_VANILLA_LOCALISATION_FILE}"
#checkForMismatchingLocationLinks "CK3AEP"    "${CK3AEP_VANILLA_LANDED_TITLES_FILE}"   "${CK3AEP_LOCALISATIONS_DIR}/AEP_titles_l_english.yml" "${CK3_VANILLA_LOCALISATION_FILE}"
checkForMismatchingLocationLinks "CK3ATHA"  "${CK3ATHA_VANILLA_LANDED_TITLES_FILE}" "${CK3ATHA_LOCALISATIONS_DIR}"/ATHA_titles_*_l_english.yml
checkForMismatchingLocationLinks "CK3CE"    "${CK3CE_VANILLA_LANDED_TITLES_FILE}"   "${CK3CE_LOCALISATIONS_DIR}"/*_titles_l_english.yml "${CK3_VANILLA_LOCALISATION_FILE}"
checkForMismatchingLocationLinks "CK3CMH"   "${CK3CMH_VANILLA_LANDED_TITLES_FILE}"  "${CK3CE_VANILLA_LOCALISATION_FILE}" "${CK3Counterfactuals_VANILLA_LOCALISATION_FILE}" "${CK3IBL_VANILLA_LOCALISATION_FILE}" "${CK3RICE_VANILLA_LOCALISATION_FILE}" "${CK3SuccExp_VANILLA_LOCALISATION_FILE}" "${CK3Trinity_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
checkForMismatchingLocationLinks "CK3IBL"   "${CK3IBL_VANILLA_LANDED_TITLES_FILE}"  "${CK3IBL_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
#checkForMismatchingLocationLinks "CK3MBP"   "${CK3MBP_VANILLA_LANDED_TITLES_FILE}"  "${CK3MBP_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
checkForMismatchingLocationLinks "CK3SoW"   "${CK3SoW_VANILLA_LANDED_TITLES_FILE}"  "${CK3SoW_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
#checkForMismatchingLocationLinks "CK3TBA"   "${CK3TBA_VANILLA_LANDED_TITLES_FILE}"  "${CK3TBA_VANILLA_LOCALISATION_FILE}"
checkForMismatchingLocationLinks "CK3TFE"   "${CK3TFE_VANILLA_LANDED_TITLES_FILE}"  "${CK3TFE_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
#checkForMismatchingLocationLinks 'HOI4'
#checkForMismatchingLocationLinks 'HOI4MDM'
checkForMismatchingLocationLinks 'HOI4TGW'
checkForMismatchingLocationLinks "IR"       "${IR_VANILLA_FILE}"
checkForMismatchingLocationLinks "IR_ABW"   "${IR_ABW_VANILLA_FILE}"
checkForMismatchingLocationLinks "IR_AoE"   "${IR_AoE_VANILLA_FILE}"
checkForMismatchingLocationLinks "IR_INV"   "${IR_INV_VANILLA_FILE}"
checkForMismatchingLocationLinks "IR_TBA"   "${IR_TBA_VANILLA_FILE}"
checkForMismatchingLocationLinks "IR_TI"    "${IR_TI_VANILLA_FILE}"
#checkForMismatchingLinks "Vic3"

# Validate default localisations
checkDefaultCk2Localisations "CK2"      "${CK2_LOCALISATIONS_DIR}"/*.csv
checkDefaultCk2Localisations "CK2HIP"   "${CK2HIP_LOCALISATIONS_DIR}"/*.csv
checkDefaultCk2Localisations "CK2RoI"   "${CK2RoI_LOCALISATIONS_DIR}"/*.csv
checkDefaultCk2Localisations "CK2TWK"   "${CK2TWK_LOCALISATIONS_DIR}"/*.csv
checkDefaultCk3Localisations "CK3"      "${CK3_VANILLA_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3AEP"   "${CK3AEP_LOCALISATIONS_DIR}"/AEP_titles_l_english.yml "${CK3_VANILLA_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_LOCALISATIONS_DIR}"/ATHA_titles_*_l_english.yml
checkDefaultCk3Localisations "CK3CE"    "${CK3CE_LOCALISATIONS_DIR}"/*_titles_l_english.yml "${CK3_VANILLA_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3CMH"   "${CK3CE_VANILLA_LOCALISATION_FILE}" "${CK3Counterfactuals_VANILLA_LOCALISATION_FILE}" "${CK3IBL_VANILLA_LOCALISATION_FILE}" "${CK3RICE_VANILLA_LOCALISATION_FILE}" "${CK3SuccExp_VANILLA_LOCALISATION_FILE}" "${CK3Trinity_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3IBL"   "${CK3IBL_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3MBP"   "${CK3MBP_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3SoW"   "${CK3SoW_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3TBA"   "${CK3TBA_VANILLA_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3TFE"   "${CK3TFE_VANILLA_LOCALISATION_FILE}" "${CK3_VANILLA_LOCALISATION_FILE}"

checkDefaultHoi4Localisations "HOI4"    "${HOI4_LOCALISATIONS_DIR}"
checkDefaultHoi4Localisations "HOI4MDM" "${HOI4MDM_LOCALISATIONS_DIR}"
checkDefaultHoi4Localisations "HOI4TGW" "${HOI4TGW_LOCALISATIONS_DIR}"

checkDefaultIrLocalisations "IR"        "${IR_VANILLA_FILE}"
checkDefaultIrLocalisations "IR_ABW"    "${IR_ABW_VANILLA_FILE}"
checkDefaultIrLocalisations "IR_AoE"    "${IR_AoE_VANILLA_FILE}"
checkDefaultIrLocalisations "IR_INV"    "${IR_INV_VANILLA_FILE}"
checkDefaultIrLocalisations "IR_TBA"    "${IR_TBA_VANILLA_FILE}"

checkDefaultVic3Localisations "Vic3" "${Vic3_LOCALISATIONS_DIR}"

# Find redundant names
#findRedundantNames "Hungarian" "Hungarian_Old"
findRedundantNames "Albanian" "Albanian_Medieval"
findRedundantNames "Alemannic" "Alemannic_Medieval"
findRedundantNames "Arabic" "Arabic_Classical" "Arabic_Egyptian" "Arabic_Maghrebi"
findRedundantNames "Armenian" "Armenian_Middle"
findRedundantNames "Bavarian" "Bavarian_Medieval"
findRedundantNames "Breton" "Breton_Middle"
findRedundantNames "Bulgarian" "Bulgarian_Old"
findRedundantNames "Catalan" "Catalan_Old"
findRedundantNames "Czech" "Czech_Medieval"
findRedundantNames "Dalmatian" "Dalmatian_Medieval"
findRedundantNames "Danish" "Danish_Middle"
findRedundantNames "Dutch" "Dutch_Middle"
findRedundantNames "English" "English_Middle"
findRedundantNames "French_Middle" "French_Old"
findRedundantNames "French" "French_Old"
findRedundantNames "Galician" "Galician_Medieval"
findRedundantNames "Genoese" "Genoese_Medieval"
findRedundantNames "German" "German_Middle_High"
findRedundantNames "Greek_Ancient" "Greek_Medieval"
findRedundantNames "Greek" "Greek_Medieval" "Greek_Ancient"
findRedundantNames "Icelandic" "Icelandic_Old"
findRedundantNames "Irish" "Irish_Middle"
findRedundantNames "Italian" "Dalmatian_Medieval" "Dalmatian" "Langobardic" "Ligurian_Medieval" "Lombard_Medieval" "Neapolitan_Medieval" "Sicilian_Medieval" "Tuscan_Medieval"
findRedundantNames "Kyrgyz" "Kyrgyz_Medieval"
findRedundantNames "Latin_Old" "Latin_Classical"
findRedundantNames "Latvian" "Latvian_Medieval"
findRedundantNames "Ligurian" "Ligurian_Medieval"
findRedundantNames "Lithuanian" "Lithuanian_Medieval"
findRedundantNames "Livonian" "Livonian_Medieval"
findRedundantNames "Lombard" "Lombard_Medieval"
findRedundantNames "Neapolitan" "Neapolitan_Medieval"
findRedundantNames "Norse" "Danish_Middle" "Danish_Old" "English_Old_Norse" "Gothic" "Icelandic_Old" "Irish_Middle_Norse" "Norwegian_Old" "Swedish_Old"
findRedundantNames "Norwegian" "Norwegian_Nynorsk"
findRedundantNames "Norwegian" "Norwegian_Old"
findRedundantNames "Occitan" "Occitan_Old"
findRedundantNames "Polish" "Polish_Old"
findRedundantNames "Portuguese" "Portuguese_Old"
findRedundantNames "Sami" "Sami_Medieval"
findRedundantNames "Scottish_Gaelic" "Scottish_Gaelic_Medieval"
findRedundantNames "SerboCroatian" "SerboCroatian_Medieval" "Slovene_Medieval"
findRedundantNames "SerboCroatian_Medieval" "Slovene_Medieval"
findRedundantNames "Sicilian" "Sicilian_Medieval"
findRedundantNames "Slovak" "Slovak_Medieval"
findRedundantNames "Slovene" "Slovene_Medieval"
findRedundantNames "Spanish" "Castilian_Old"
findRedundantNames "Turkish" "Turkish_Old"
findRedundantNames "Tuscan_Medieval" "Corsican" "Dalmatian_Medieval" "Dalmatian" "Langobardic" "Ligurian_Medieval" "Ligurian" "Lombard_Medieval" "Lombard" "Neapolitan_Medieval" "Sardinian" "Sicilian_Medieval" "Sicilian"
findRedundantNames "Vepsian" "Vepsian_Medieval"
findRedundantNames "Welsh_Middle" "Welsh_Old"
findRedundantNames "Welsh" "Welsh_Middle"
wait
