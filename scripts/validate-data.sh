#!/bin/bash

LANGUAGES_FILE="languages.xml"
LOCATIONS_FILE="locations.xml"
TITLES_FILE="titles.xml"

if [ -d "${HOME}/.games/Steam/common" ]; then
    STEAM_GAMES_PATH="${HOME}/.games/Steam/common"
elif [ -d "${HOME}/.local/share/Steam/steamapps/common" ]; then
    STEAM_GAMES_PATH="${HOME}/.local/share/Steam/steamapps/common"
fi

CK2_VANILLA_LANDED_TITLES_FILE="more-cultural-names-builder/Data/ck2_landed_titles.txt"
CK2HIP_VANILLA_LANDED_TITLES_FILE="more-cultural-names-builder/Data/ck2hip_landed_titles.txt"
CK3_VANILLA_LANDED_TITLES_FILE="more-cultural-names-builder/Data/ck3_landed_titles.txt"

CK3_VANILLA_LOCALISATION_FILE="${STEAM_GAMES_PATH}/Crusader Kings III/game/localization/english/titles_l_english.yml"
IMPERATORROME_VANILLA_LOCALISATION_FILE="${STEAM_GAMES_PATH}/ImperatorRome/game/localization/english/provincenames_l_english.yml"

LOCATION_IDS="$(grep "<Id>" "${LOCATIONS_FILE}" | sed 's/[^>]*>\([^<]*\).*/\1/g' | sort)"

function getGameIds() {
    GAME="${1}"

    grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
        sed 's/[^>]*>\([^<]*\).*/\1/g' | \
        sort
}

function checkForMissingCkTitles() {
    GAME="${1}"
    LANDED_TITLES_FILE="${2}"

    for TITLE_ID in $(diff \
                        <(getGameIds "${GAME}") \
                        <( \
                            cat "${LANDED_TITLES_FILE}" | \
                            if [ -n "$(file ${LANDED_TITLES_FILE} | grep Non-ISO)" ]
                            then
                                iconv -f WINDOWS-1252 -t UTF-8 2> /dev/null
                            else
                                cat
                            fi | \
                            grep -i "^\s*[ekdcb]_.*=" | \
                            awk -F"=" '{print $1}' | \
                            sed 's/[^a-zA-Z0-9_\-]//g' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g'); do
        LOCATION_ID=${TITLE_ID:2}
        if [ -z "$(echo "${LOCATION_IDS}" | grep -Eio "^${LOCATION_ID}$")" ]; then
            echo "    > ${GAME}: ${TITLE_ID} is missing"
        else
            echo "    > ${GAME}: ${TITLE_ID} is missing (but location \"${LOCATION_ID}\" exists)"
        fi
    done
}

function checkForSurplusCkTitles() {
    GAME="${1}"
    LANDED_TITLES_FILE="${2}"

    for TITLE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort \
                        ) <( \
                            cat "${LANDED_TITLES_FILE}" | \
                            if [ -n "$(file ${LANDED_TITLES_FILE} | grep Non-ISO)" ]
                            then
                                iconv -f WINDOWS-1252 -t UTF-8 2> /dev/null
                            else
                                cat
                            fi | \
                            grep -i "^\s*[ekdcb]_.*=" | \
                            awk -F"=" '{print $1}' | \
                            sed 's/[^a-zA-Z0-9_\-]//g' | \
                            sort | uniq \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    < ${GAME}: ${TITLE_ID} is defined but it does not exist"
    done
}

function checkForMismatchingCkTitles() {
    GAME="${1}"
    LANDED_TITLES_FILE="${2}"

    checkForMissingCkTitles "${GAME}" "${LANDED_TITLES_FILE}"
    checkForSurplusCkTitles "${GAME}" "${LANDED_TITLES_FILE}"
}

# Find duplicated IDs
grep "^ *<Id>" *.xml | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find duplicated game IDs
grep "<GameId game=" *.xml | \
    sed -e 's/[ \t]*<!--.*-->.*//g' -e 's/^[ \t]*//g' | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find empty definitions
grep "><" "${LOCATIONS_FILE}" "${LANGUAGES_FILE}" "${TITLES_FILE}"

# Validate XML structure
grep -Pzo "</GameIds>\n *<Name " "${LOCATIONS_FILE}"
grep -Pzo "<GameId .*\n *<Name" "${LOCATIONS_FILE}"

# Find non-existing fallback locations
for FALLBACK_LOCATION_ID in $(diff \
                    <( \
                        grep "<LocationId>" "${LOCATIONS_FILE}" | \
                        sed 's/.*<LocationId>\([^<>]*\)<\/LocationId>.*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        echo ${LOCATION_IDS} | \
                        sed 's/ /\n/g') | \
                    grep "^<" | sed 's/^< //g' | sed 's/ /@/g'); do
    echo "The \"${FALLBACK_LOCATION_ID}\" fallback location does not exit"
done

# Find non-existing fallback titles
for FALLBACK_TITLE_ID in $(diff \
                    <( \
                        grep "<TitleId>" "${TITLES_FILE}" | \
                        sed 's/.*<TitleId>\([^<>]*\)<\/TitleId>.*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        grep "<Id>" "${TITLES_FILE}" | \
                        sed 's/^[^<]*<Id>\([^<]*\).*/\1/g' | \
                        sort | uniq \
                    ) | \
                    grep "^<" | sed 's/^< //g' | sed 's/ /@/g'); do
    echo "The \"${FALLBACK_TITLE_ID}\" fallback title does not exit"
done

# Find non-existing name languages
for LANGUAGE_ID in $(diff \
                    <( \
                        grep "<Name " *.xml | \
                        sed 's/.*language=\"\([^\"]*\).*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        grep "<Id>" "${LANGUAGES_FILE}" | \
                        sed 's/^[^<]*<Id>\([^<]*\).*/\1/g' | \
                        sort | uniq \
                    ) | \
                    grep "^<" | sed 's/^< //g' | sed 's/ /@/g'); do
    echo "The \"${LANGUAGE_ID}\" language does not exit"
done

# Find multiple name definitions for the same language
pcregrep -M "language=\"([^\"]*)\".*\n.*language=\"\1\"" *.xml

# Make sure all CK titles are defined and exist in the game
checkForMismatchingCkTitles "CK2" "${CK2_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingCkTitles "CK2HIP" "${CK2HIP_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingCkTitles "CK3" "${CK3_VANILLA_LANDED_TITLES_FILE}"

# Validate default localisations for CK3
for GAMEID_DEFINITION in $(diff \
                    <( \
                        grep "GameId game=\"CK3\"" "${LOCATIONS_FILE}" | \
                        sed 's/^ *//g' |
                        sort
                    ) <( \
                        awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                            <(getGameIds "CK3") \
                            <( \
                                cat "${CK3_VANILLA_LOCALISATION_FILE}" | \
                                grep "^ *[ekdcb]_" | grep -v "_adj:" | \
                                sed 's/^ *\([^:]*\):[0-9]* *\"\([^\"]*\).*/\1=\2/g' | \
                                sed -e 's/= */=/g' -e 's/ *$//g'
                            ) | \
                        awk -F"=" '{print "<GameId game=\"CK3\">"$1"</GameId> <!-- "$2" -->"}' | \
                        sort | uniq \
                    ) | \
                    grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
    echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
done

# Validate default localisations for ImperatorRome
for GAMEID_DEFINITION in $(diff \
                    <( \
                        grep "GameId game=\"ImperatorRome\"" "${LOCATIONS_FILE}" | \
                        sed 's/^ *//g' |
                        sort
                    ) <( \
                        awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                            <(getGameIds "ImperatorRome") \
                            <( \
                                cat "${IMPERATORROME_VANILLA_LOCALISATION_FILE}" | \
                                grep "^ *PROV" | grep -v "_[A-Za-z_-]*:" | \
                                sed 's/^ *PROV\([0-9]*\):[0-9]* *\"\([^\"]*\).*/\1=\2/g' | \
                                sed -e 's/= */=/g' -e 's/ *$//g'
                            ) | \
                        awk -F"=" '{print "<GameId game=\"ImperatorRome\">"$1"</GameId> <!-- "$2" -->"}' | \
                        sort | uniq \
                    ) | \
                    grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
    echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
done
