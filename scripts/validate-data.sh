#!/bin/bash
source "scripts/common/paths.sh"

LANGUAGE_IDS="$(grep "<Id>" "${LANGUAGES_FILE}" | sed 's/[^>]*>\([^<]*\).*/\1/g' | sort)"
LOCATION_IDS="$(grep "<Id>" "${LOCATIONS_FILE}" | sed 's/[^>]*>\([^<]*\).*/\1/g' | sort)"

GAME_IDS_CK="$(grep "<GameId game=\"CK" "${LOCATIONS_FILE}" | sed 's/^[^>]*>\([^<]*\).*/\1/g' | sort | uniq)"

function getGameIds() {
    local GAME="${1}"

    grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
        sed 's/[^>]*>\([^<]*\).*/\1/g' | \
        sort
}

function checkForSurplusCk3LanguageLinks() {
    local GAME="${1}"
    local CULTURES_DIR="${2}"
    local INHERITS_FROM_VANILLA=${3}

    for TITLE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME}\"" "${LANGUAGES_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) <( \
                            if ${INHERITS_FROM_VANILLA}; then
                                cat "${CK3_CULTURES_DIR}"/*.txt "${CULTURES_DIR}"/*.txt
                            else
                                cat "${CULTURES_DIR}"/*.txt
                            fi | \
                            grep -P '^\s*name_list\s*=' | \
                            awk -F"=" '{print $2}' | \
                            sed 's/\s//g' | \
                            sed 's/#.*//g' | \
                            sed 's/^name_list_//g' | \
                            sort | uniq \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME}: ${TITLE_ID} is defined but it does not exist"
    done
}

function checkForMismatchingLanguageLinks() {
    local GAME="${1}"
    local CULTURES_DIR="${2}"
    local INHERITS_FROM_VANILLA=false

    [ ! -d "${CULTURES_DIR}" ] && return

    [ -n "${3}" ] && INHERITS_FROM_VANILLA=${3}

    if [[ ${GAME} == CK3* ]]; then
        checkForSurplusCk3LanguageLinks "${GAME}" "${CULTURES_DIR}" ${INHERITS_FROM_VANILLA}
    fi
}

function checkForMissingCkLocationLinks() {
    local GAME="${1}"
    local VANILLA_FILE="${2}"

    for TITLE_ID in $(diff \
                        <(getGameIds "${GAME}") \
                        <( \
                            cat "${VANILLA_FILE}" | \
                            if file "${VANILLA_FILE}" | grep -q 'Non-ISO\|ISO-8859'; then
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
        LOCATION_ID_FOR_SEARCH=$(echo "${LOCATION_ID}" | sed \
            -e 's/[_-]//g' \
            -e 's/\(baron\|castle\|church\|city\|fort\|temple\|town\)//g')

        if $(echo "${LOCATION_IDS}" | sed 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME}: ${TITLE_ID} is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
        elif $(echo "${GAME_IDS_CK}" | sed -e 's/^..//g' -e 's/[_-]//g' | grep -Eioq "^${LOCATION_ID_FOR_SEARCH}$"); then
            echo "    > ${GAME}: ${TITLE_ID} is missing (but location \"${LOCATION_ID_FOR_SEARCH}\" exists)"
        else
            echo "    > ${GAME}: ${TITLE_ID} is missing"
        fi
    done
}

function checkForSurplusCkLocationLinks() {
    local GAME="${1}"
    local VANILLA_FILE="${2}"

    for TITLE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) <( \
                            cat "${VANILLA_FILE}" | \
                            if file "${VANILLA_FILE}" | grep -q 'Non-ISO\|ISO-8859'; then
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
        echo "    > ${GAME}: ${TITLE_ID} is defined but it does not exist"
    done
}

function checkForSurplusIrLocationLinks() {
    local GAME="${1}"
    local VANILLA_FILE="${2}"

    for TITLE_ID in $(diff \
                        <( \
                            grep "GameId game=\"${GAME}\"" "${LOCATIONS_FILE}" | \
                            sed 's/[^>]*>\([^<]*\).*/\1/g' | \
                            sort | uniq \
                        ) <( \
                            grep -i "^\s*PROV[0-9]*:.*" "${VANILLA_FILE}" | \
                            sed 's/^\s*PROV\([0-9]*\):.*$/\1/g' | \
                            sort | uniq \
                        ) | \
                        grep "^<" | sed 's/^< //g'); do
        echo "    > ${GAME}: ${TITLE_ID} is defined but it does not exist"
    done
}

function checkForMismatchingLocationLinks() {
    local GAME="${1}"
    local VANILLA_FILE="${2}"

    [ ! -f "${VANILLA_FILE}" ] && return

    if [[ ${GAME} == CK* ]]; then
        checkForMissingCkLocationLinks "${GAME}" "${VANILLA_FILE}"
        checkForSurplusCkLocationLinks "${GAME}" "${VANILLA_FILE}"
    elif [[ ${GAME} == IR* ]]; then
        checkForSurplusIrLocationLinks "${GAME}" "${VANILLA_FILE}"
    fi
}

function checkDefaultCk2Localisations() {
    local GAME_ID="${1}"
    local LOCALISATIONS_DIR="${2}"

    [ ! -d "${LOCALISATIONS_DIR}" ] && return

    for GAMEID_DEFINITION in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/^ *//g' |
                            sort
                        ) <( \
                            awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                                <(getGameIds "${GAME_ID}") \
                                <( \
                                    tac "${LOCALISATIONS_DIR}"/*.csv | grep "^[ekdcb]_" | \
                                    grep -v "_adj\(_[a-z]*\)*;" | \
                                    awk -F";" '!seen[$1]++' | \
                                    awk -F";" '{print $1"="$2}' | \
                                    sed -e 's/\s*=\s*/=/g' -e 's/ *$//g'
                                ) | \
                            awk -F"=" '{print "<GameId game=\"'${GAME_ID}'\">"$1"</GameId> <!-- "$2" -->"}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
        echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
    done
}

function checkDefaultCk3Localisations() {
    local GAME_ID="${1}"
    local LOCALISATIONS_FILE="${2}"

    [ ! -f "${LOCALISATIONS_FILE}" ] && return

    for GAMEID_DEFINITION in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/^ *//g' |
                            sort
                        ) <( \
                            awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                                <(getGameIds "${GAME_ID}") \
                                <( \
                                    tac "${LOCALISATIONS_FILE}" | grep "^ *[ekdcb]_" | \
                                    grep -v "_adj:" | \
                                    sed 's/^ *\([^:]*\):[0-9]* *\"\([^\"]*\).*/\1=\2/g' | \
                                    awk -F"=" '!seen[$1]++' | \
                                    sed -e 's/= */=/g' -e 's/ *$//g'
                                ) | \
                            awk -F"=" '{print "<GameId game=\"'${GAME_ID}'\">"$1"</GameId> <!-- "$2" -->"}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
        echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
    done
}

function checkDefaultIrLocalisations() {
    local GAME_ID="${1}"
    local LOCALISATIONS_FILE="${2}"

    [ ! -f "${LOCALISATIONS_FILE}" ] && return

    for GAMEID_DEFINITION in $(diff \
                        <( \
                            grep "GameId game=\"${GAME_ID}\"" "${LOCATIONS_FILE}" | \
                            sed 's/^ *//g' |
                            sort
                        ) <( \
                            awk -F= 'NR==FNR{a[$0]; next} $1 in a' \
                                <(getGameIds "${GAME_ID}") \
                                <( \
                                    tac "${LOCALISATIONS_FILE}" "${IR_VANILLA_FILE}" | \
                                    grep "^ *PROV" | \
                                    grep -v "_[A-Za-z_-]*:" | \
                                    awk '!x[substr($0,0,9)]++' | \
                                    sed 's/^ *PROV\([0-9]*\):[0-9]* *\"\([^\"]*\).*/\1=\2/g' | \
                                    sed -e 's/= */=/g' -e 's/ *$//g'
                                ) | \
                            awk -F"=" '{print "<GameId game=\"'${GAME_ID}'\">"$1"</GameId> <!-- "$2" -->"}' | \
                            sort | uniq \
                        ) | \
                        grep "^>" | sed 's/^> //g' | sed 's/ /@/g'); do
        echo "Wrong default localisation! Correct one is: ${GAMEID_DEFINITION}" | sed 's/@/ /g'
    done
}

function validateHoi4Parentage() {
    local GAME_ID="${1}"

    for STATE_ID in $(grep "${GAME_ID}\" type=\"City" "${LOCATIONS_FILE}" | \
                            sed 's/.*parent=\"\([^\"]*\).*/\1/g' | \
                            sort -g | uniq); do
        if ! grep -q "${GAME_ID}\" type=\"State\">${STATE_ID}<" "${LOCATIONS_FILE}"; then
            echo "${GAME_ID}: State #${STATE_ID} is missing while there are cities referencing it"
        fi
    done
}

function findRedundantNames() {
    local PRIMARY_LANGUAGE_ID="${1}"
    local SECONDARY_LANGUAGE_ID="${2}"

    grep -Pzo "\s*<Name language=\"${PRIMARY_LANGUAGE_ID}\" value=\"([^\"]*)\" />\n\s*<Name language=\"${SECONDARY_LANGUAGE_ID}\" value=\"\1\" />\n" "${LOCATIONS_FILE}" | grep -a "\"${SECONDARY_LANGUAGE_ID}\""
    grep -Pzo "\s*<Name language=\"${SECONDARY_LANGUAGE_ID}\" value=\"([^\"]*)\" />\n\s*<Name language=\"${PRIMARY_LANGUAGE_ID}\" value=\"\1\" />\n" "${LOCATIONS_FILE}" | grep -a "\"${SECONDARY_LANGUAGE_ID}\""
}

function findRedundantNamesStrict() {
    local PRIMARY_LANGUAGE_ID="${1}"
    local SECONDARY_LANGUAGE_ID="${2}"

    grep -Pzo "\s*<Name language=\"${PRIMARY_LANGUAGE_ID}\" value=\"([^\"]*)\" />(\n\s*<Name .*)*\n\s*<Name language=\"${SECONDARY_LANGUAGE_ID}\" value=\"\1\" />\n" "${LOCATIONS_FILE}" | grep -a "\"${SECONDARY_LANGUAGE_ID}\""
    grep -Pzo "\s*<Name language=\"${SECONDARY_LANGUAGE_ID}\" value=\"([^\"]*)\" />(\n\s*<Name .*)*\n\s*<Name language=\"${PRIMARY_LANGUAGE_ID}\" value=\"\1\" />\n" "${LOCATIONS_FILE}" | grep -a "\"${SECONDARY_LANGUAGE_ID}\""
}

### Make sure locations are sorted alphabetically

OLD_LC_COLLATE=${LC_COLLATE}
export LC_COLLATE=C

WELL_COVERED_SECTION_END_LINE_NR=$(grep -n "@@@@ BELOW TITLES NEED REVIEW" "${LOCATIONS_FILE}" | awk -F":" '{print $1}')
ACTUAL_LOCATIONS_LIST=$(head "${LOCATIONS_FILE}" -n "${WELL_COVERED_SECTION_END_LINE_NR}" | \
                        grep "^\s*<Id>" | \
                        sed 's/^\s*<Id>\([^<]*\).*/\1/g' | \
                        sed -r '/^\s*$/d' | \
                        perl -p0e 's/\r*\n/%NL%/g')
EXPECTED_LOCATIONS_LIST=$(echo "${ACTUAL_LOCATIONS_LIST}" | \
                            sed 's/%NL%/\n/g' | \
                            sort | \
                            sed -r '/^\s*$/d' | \
                            perl -p0e 's/\r*\n/%NL%/g')

diff --context=1 --color --suppress-common-lines <(echo "${ACTUAL_LOCATIONS_LIST}" | sed 's/%NL%/\n/g') <(echo "${EXPECTED_LOCATIONS_LIST}" | sed 's/%NL%/\n/g')
export LC_COLLATE=${OLD_LC_COLLATE}

# Find duplicated IDs
grep "^ *<Id>" *.xml | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find duplicated game IDs
grep "<GameId game=" *.xml | \
    sed -e 's/[ \t]*<!--.*-->.*//g' -e 's/^[ \t]*//g' | \
    sort | uniq -c | \
    grep "^ *[2-9]"

# Find duplicated names
grep -Pzo "\n *<Name language=\"([^\"]*)\" value=\"([^\"]*)\" />((\n *<Name l.*)*)\n *<Name language=\"\1\" value=\"\2\" />.*\n" *.xml

# Find empty definitions
grep "><" "${LOCATIONS_FILE}" "${LANGUAGES_FILE}" "${TITLES_FILE}"

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
grep -Pzo "\n *</Names.*\n *</*(Names|GameId).*\n" *.xml
grep -Pzo "\n *<Names>\n *<[^N].*\n" *.xml
grep -Pzo "\n *<Name .*\n *</L.*\n" *.xml
grep -Pzo "\n *</GameIds>\n *<Name .*\n" *.xml
grep -Pzo "\n *<GameId .*\n *<Name.*\n" *.xml
grep -Pzo "\n *<(/*)GameIds.*\n *<\1GameIds.*\n" *.xml
grep -Pzo "\n *<GameIds>\n *<[^G].*\n" *.xml
grep -Pzo "\n\s*<Language>\n\s*<[^I][^d].*\n" *.xml # Missing Id (right after definition)
grep -n "^\s*</[^>]*>\s*[a-zA-Z0-9\s]" *.xml # Text after ending tags
grep -Pzo "\n\s*<(/[^>]*)>.*\n\s*<\1>\n" *.xml # Double tags
grep -Pzo "\n\s*<([^>]*)>\s*\n\s*</\1>\n" *.xml # Empty tags
grep -Pzo "\n\s*<Name .*\n\s*</GameId.*\n" *.xml # </GameId.* after <Name>
grep -Pzo "</(GeonamesId|WikidataId)>.*\n\s*</GameId.*\n" *.xml # </GameId.* after </GeonamesId> or </WikidataId>
grep -Pzo "\s*([^=\s]*)\s*=\s*\"[^\"]*\"\s*\1\s*=\"[^\"]*\".*\n" *.xml # Double attributes
grep -Pzo "\n.*=\s*\"\s*\".*\n" *.xml # Empty attributes
grep -n "^\s*<\([^> ]*\).*<\/.*" *.xml | grep -v "^[a-z0-9:.]*\s*<\([^> ]*\).*<\/\1>.*" # Mismatching start/end tag on same line
grep -Pzo "\n *</(Language|Location|Title)>.*\n *<Fallback.*\n" *.xml
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

# Find non-existing fallback languages
for FALLBACK_LANGUAGE_ID in $(diff \
                    <( \
                        grep "<LanguageId>" "${LANGUAGES_FILE}" | \
                        sed 's/.*<LanguageId>\([^<>]*\)<\/LanguageId>.*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        echo "${LANGUAGE_IDS}" | \
                        sed 's/ /\n/g') | \
                    grep "^<" | sed 's/^< //g' | sed 's/ /@/g'); do
    echo "The \"${FALLBACK_LANGUAGE_ID}\" fallback language does not exit"
done

# Find non-existing fallback locations
for FALLBACK_LOCATION_ID in $(diff \
                    <( \
                        grep "<LocationId>" "${LOCATIONS_FILE}" | \
                        sed 's/.*<LocationId>\([^<>]*\)<\/LocationId>.*/\1/g' | \
                        sort | uniq \
                    ) <( \
                        echo "${LOCATION_IDS}" | \
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
grep -Pzo "\n.* language=\"([^\"]*)\".*\n.*language=\"\1\".*\n" *.xml

# Make sure all languages exist in the game
checkForMismatchingLanguageLinks "CK3"      "${CK3_CULTURES_DIR}"
checkForMismatchingLanguageLinks "CK3ATHA"  "${CK3ATHA_CULTURES_DIR}"
checkForMismatchingLanguageLinks "CK3IBL"   "${CK3IBL_CULTURES_DIR}" true
checkForMismatchingLanguageLinks "CK3MBP"   "${CK3MBP_CULTURES_DIR}" true

# Make sure all locations are defined and exist in the game
checkForMismatchingLocationLinks "CK2"      "${CK2_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingLocationLinks "CK2HIP"   "${CK2HIP_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingLocationLinks "CK3"      "${CK3_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingLocationLinks "CK3ATHA"  "${CK3ATHA_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingLocationLinks "CK3IBL"   "${CK3IBL_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingLocationLinks "CK3MBP"   "${CK3MBP_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingLocationLinks "CK3TFE"   "${CK3TFE_VANILLA_LANDED_TITLES_FILE}"
checkForMismatchingLocationLinks "IR"       "${IR_VANILLA_FILE}"
checkForMismatchingLocationLinks "IR_AoE"   "${IR_AoE_VANILLA_FILE}"

validateHoi4Parentage "HOI4"
validateHoi4Parentage "HOI4TGW"

# Validate default localisations
#checkDefaultCk2Localisations "CK2"      "${CK2_LOCALISATIONS_DIR}"
checkDefaultCk2Localisations "CK2HIP"   "${CK2HIP_LOCALISATIONS_DIR}"
checkDefaultCk3Localisations "CK3"      "${CK3_VANILLA_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_BARONIES_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_COUNTIES_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_DUCHIES_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_KINGDOMS_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_EMPIRES_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3ATHA"  "${CK3ATHA_VANILLA_SPECIAL_LOCALISATION_FILE}"
#checkDefaultCk3Localisations "CK3TFE"   "${CK3TFE_VANILLA_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3IBL"   "${CK3IBL_VANILLA_LOCALISATION_FILE}"
checkDefaultCk3Localisations "CK3MBP"   "${CK3MBP_VANILLA_LOCALISATION_FILE}"
checkDefaultIrLocalisations  "IR"       "${IR_VANILLA_FILE}"
checkDefaultIrLocalisations  "IR_AoE"   "${IR_AoE_VANILLA_FILE}"

# Find redundant names
findRedundantNames "Albanian" "Albanian_Medieval"
findRedundantNames "Alemannic" "Alemannic_Medieval"
findRedundantNames "Arabic" "Arabic_Medieval"
findRedundantNames "Armenian" "Armenian_Middle"
findRedundantNames "Asturian" "Asturian_Medieval"
findRedundantNames "Bashkir" "Bashkir_Medieval"
findRedundantNames "Basque" "Basque_Medieval"
findRedundantNames "Bavarian" "Bavarian_Medieval"
findRedundantNames "Breton" "Breton_Middle"
findRedundantNames "Bulgarian" "Bulgarian_Old"
findRedundantNames "Castilian" "Castilian_Old"
findRedundantNames "Catalan" "Catalan_Old"
findRedundantNames "Croatian" "Croatian_Medieval"
findRedundantNames "Czech" "Czech_Medieval"
findRedundantNames "Dalmatian" "Dalmatian_Medieval"
findRedundantNames "Danish" "Danish_Middle"
findRedundantNames "Dutch" "Dutch_Middle"
findRedundantNames "English" "English_Middle"
findRedundantNames "Estonian" "Estonian_Medieval"
findRedundantNames "Finnish" "Finnish_Medieval"
findRedundantNames "French" "French_Old"
findRedundantNames "Galician" "Galician_Medieval"
findRedundantNames "Genoese" "Genoese_Medieval"
findRedundantNames "German" "German_Middle_High"
findRedundantNames "Greek_Ancient" "Greek_Medieval"
findRedundantNames "Hungarian" "Hungarian_Old"
findRedundantNames "Icelandic" "Icelandic_Old"
findRedundantNames "Irish" "Irish_Middle"
findRedundantNames "Khazar" "Khazar_Medieval"
findRedundantNames "Kyrgyz" "Kyrgyz_Medieval"
findRedundantNames "Latin_Old" "Latin_Classical"
findRedundantNames "Latvian" "Latvian_Medieval"
findRedundantNames "Ligurian" "Ligurian_Medieval"
findRedundantNames "Lithuanian" "Lithuanian_Medieval"
findRedundantNames "Livonian" "Livonian_Medieval"
findRedundantNames "Lombard" "Lombard_Medieval"
findRedundantNames "Neapolitan" "Neapolitan_Medieval"
findRedundantNames "Norwegian" "Norwegian_Nynorsk"
findRedundantNames "Norwegian" "Norwegian_Old"
findRedundantNames "Occitan" "Occitan_Old"
findRedundantNames "Polish" "Polish_Old"
findRedundantNames "Portuguese" "Portuguese_Old"
findRedundantNames "Romanian" "Romanian_Old"
findRedundantNames "Russian" "Russian_Medieval"
findRedundantNames "Sami" "Sami_Medieval"
findRedundantNames "Samogitian" "Samogitian_Medieval"
findRedundantNames "Scottish_Gaelic" "Scottish_Gaelic_Medieval"
findRedundantNames "Serbian" "Serbian_Medieval"
findRedundantNames "SerboCroatian" "Serbian_Medieval"
findRedundantNames "SerboCroatian" "Serbian"
findRedundantNames "SerboCroatian" "SerboCroatian_Medieval"
findRedundantNames "SerboCroatian" "Slovene_Medieval"
findRedundantNames "Sicilian" "Sicilian_Medieval"
findRedundantNames "Slovak" "Slovak_Medieval"
findRedundantNames "Slovene" "Slovene_Medieval"
findRedundantNames "Tajiki" "Tajiki_Medieval"
findRedundantNames "Tajiki" "Thuringian_Medieval"
findRedundantNames "Turkish" "Turkish_Old"
findRedundantNames "Venetian" "Venetian_Medieval"
findRedundantNames "Vepsian" "Vepsian_Medieval"
findRedundantNames "Welsh_Middle" "Welsh_Old"
findRedundantNames "Welsh" "Welsh_Middle"
findRedundantNamesStrict "Italian" "Dalmatian_Medieval"
findRedundantNamesStrict "Italian" "Dalmatian"
findRedundantNamesStrict "Italian" "Langobardic"
findRedundantNamesStrict "Italian" "Ligurian_Medieval"
findRedundantNamesStrict "Italian" "Lombard_Medieval"
findRedundantNamesStrict "Italian" "Neapolitan_Medieval"
findRedundantNamesStrict "Italian" "Sicilian_Medieval"
findRedundantNamesStrict "Italian" "Tuscan_Medieval"
findRedundantNamesStrict "Italian" "Venetian_Medieval"
findRedundantNamesStrict "Norse" "Danish_Middle"
findRedundantNamesStrict "Norse" "Danish_Old"
findRedundantNamesStrict "Norse" "English_Old_Norse"
findRedundantNamesStrict "Norse" "Gothic"
findRedundantNamesStrict "Norse" "Icelandic_Old"
findRedundantNamesStrict "Norse" "Irish_Middle_Norse"
findRedundantNamesStrict "Norse" "Norwegian_Old"
findRedundantNamesStrict "Norse" "Swedish_Old"
findRedundantNamesStrict "Serbian_Medieval" "Croatian_Medieval"
findRedundantNamesStrict "Serbian" "Croatian"
findRedundantNamesStrict "SerboCroatian_Medieval" "Croatian_Medieval"
findRedundantNamesStrict "SerboCroatian_Medieval" "Croatian"
findRedundantNamesStrict "SerboCroatian_Medieval" "Serbian_Medieval"
findRedundantNamesStrict "SerboCroatian" "Croatian"
findRedundantNamesStrict "Spanish" "Castilian_Old"
findRedundantNamesStrict "Spanish" "Castilian"
findRedundantNamesStrict "Tuscan_Medieval" "Corsican"
findRedundantNamesStrict "Tuscan_Medieval" "Dalmatian_Medieval"
findRedundantNamesStrict "Tuscan_Medieval" "Dalmatian"
findRedundantNamesStrict "Tuscan_Medieval" "Langobardic"
findRedundantNamesStrict "Tuscan_Medieval" "Ligurian_Medieval"
findRedundantNamesStrict "Tuscan_Medieval" "Ligurian"
findRedundantNamesStrict "Tuscan_Medieval" "Lombard_Medieval"
findRedundantNamesStrict "Tuscan_Medieval" "Lombard"
findRedundantNamesStrict "Tuscan_Medieval" "Neapolitan_Medieval"
findRedundantNamesStrict "Tuscan_Medieval" "Sardinian"
findRedundantNamesStrict "Tuscan_Medieval" "Sicilian"
findRedundantNamesStrict "Tuscan_Medieval" "Sicilian_Medieval"
findRedundantNamesStrict "Tuscan_Medieval" "Venetian_Medieval"
wait