#!/bin/bash
LANGUAGES_FILE="languages.xml"

STEAM_APPS_DIR="${HOME}/.local/share/Steam/steamapps"
STEAM_GAMES_DIR="${STEAM_APPS_DIR}/common"
STEAM_WORKSHOP_DIR="${STEAM_APPS_DIR}/workshop"

CK2_DIR="${STEAM_GAMES_DIR}/Crusader Kings II"
CK2_CULTURES_DIR="${CK2_DIR}/common/cultures"
CK2_MODS_DIR="${HOME}/.paradoxinteractive/Crusader Kings II/mod"
CK2HIP_CULTURES_DIR="${CK2_MODS_DIR}/Historical_Immersion_Project/common/cultures"

CK3_DIR="${STEAM_GAMES_DIR}/Crusader Kings III"
CK3_CULTURES_DIR="${CK3_DIR}/game/common/culture/cultures"
CK3_WORKSHOP_MODS_DIR="${STEAM_WORKSHOP_DIR}/content/1158310"
CK3Apotheosis_CULTURES_DIR="${CK3_WORKSHOP_MODS_DIR}/2618149514/common/culture/cultures"
CK3IBL_CULTURES_DIR="${CK3_WORKSHOP_MODS_DIR}/2416949291/common/culture/cultures"
CK3MBP_CULTURES_DIR="${CK3_WORKSHOP_MODS_DIR}/2216670956/common/culture/cultures"
CK3SoW_CULTURES_DIR="${CK3_CULTURES_DIR}"
#CK3SoW_CULTURES_DIR="${CK3_WORKSHOP_MODS_DIR}/2566883856/common/culture/cultures"
CK3TFE_CULTURES_DIR="${CK3_WORKSHOP_MODS_DIR}/2243307127/common/culture/cultures"

HOI4_DIR="${STEAM_GAMES_DIR}/Hearts of Iron IV"
HOI4_WORKSHOP_MODS_DIR="${STEAM_WORKSHOP_DIR}/content/394360"
HOI4_TAGS_DIR="${HOI4_DIR}/common/country_tags"
HOI4_LOCALISATIONS_DIR="${HOI4_DIR}/localisation/english"
HOI4TGW_DIR="${HOI4_WORKSHOP_MODS_DIR}/699709023"
HOI4TGW_TAGS_DIR="${HOI4TGW_DIR}/common/country_tags"
HOI4TGW_LOCALISATIONS_DIR="${HOI4TGW_DIR}/localisation"

IR_DIR="${STEAM_GAMES_DIR}/ImperatorRome"
IR_CULTURES_DIR="${IR_DIR}/game/common/cultures"

echo "Crusader Kings 2:"

for CULTURE_ID in $(grep -P '^\t[a-z]* = {' "${CK2_CULTURES_DIR}/"* | \
                    awk -F":" '{print $2}' | \
                    sed 's/^\t*//g' | \
                    awk -F" " '{print $1}' | \
                    sort | uniq); do
    if ! grep -q '<GameId game="CK2">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
        echo "  ${CULTURE_ID}"
    fi
done

echo "Crusader Kings 2 HIP:"
for CULTURE_ID in $(grep -P '^\t[a-z]* = {' "${CK2HIP_CULTURES_DIR}/"* | \
                    awk -F":" '{print $2}' | \
                    sed 's/^\t*//g' | \
                    awk -F" " '{print $1}' | \
                    sort | uniq); do
    if ! grep -q '<GameId game="CK2HIP">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
        echo "  ${CULTURE_ID}"
    fi
done

function getCk3Cultures() {
    GAME_ID="${1}" && shift
    CULTURES_DIR="${*}"

    for CULTURE_ID in $(grep -P '^\t[a-z]* = {' "${CULTURES_DIR}/"*.txt | \
                        awk -F":" '{print $2}' | \
                        sed 's/^\t*//g' | \
                        awk -F" " '{print $1}' | \
                        sort | uniq); do
        if ! grep -q '<GameId game="'${GAME_ID}'">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
            echo "  ${CULTURE_ID}"
        fi
    done 
}

function getHoi4Countries() {
    GAME_ID="${1}"
    TAGS_DIR="${2}"
    LOCALISATIONS_DIR="${3}"

    for TAG in $(cat "${TAGS_DIR}/"*.txt | awk -F"=" '{print $1}' | sed 's/\s*//g' | sort | uniq); do
        COUNTRY_NAME=$(grep "^\s*${TAG}:0" "${LOCALISATIONS_DIR}/"*_english.yml | awk -F"\"" '{print $2}' | sed 's/^\([^\"]*\).*/\1/g' | head -n 1)

        if [ -z "${COUNTRY_NAME}" ] && [ "${LOCALISATIONS_DIR}" != "${HOI4_LOCALISATIONS_DIR}" ]; then
            COUNTRY_NAME=$(grep "^\s*${TAG}:0" "${HOI4_LOCALISATIONS_DIR}/"*_english.yml | awk -F"\"" '{print $2}' | sed 's/^\([^\"]*\).*/\1/g' | head -n 1)
        fi
        if ! grep -q '<GameId game="'${GAME_ID}'">'${TAG}'</GameId>' "${LANGUAGES_FILE}"; then
            printf "      <GameId game=\"${GAME_ID}\">${TAG}</GameId>"
            [ -n "${COUNTRY_NAME}" ] && printf " <!-- ${COUNTRY_NAME} -->"
            printf "\n"
        fi
    done 
}

function getIrCultures() {
    GAME_ID="${1}" && shift
    CULTURES_DIR="${*}"

    for CULTURE_FILE_NAME in $(ls "${CULTURES_DIR}/"*.txt); do
        CULTURE_FILE_JSON=$(sed 's/\r*//g' "${CULTURE_FILE_NAME}" | \
            sed '1s/^\xEF\xBB\xBF//' | \
            sed 's/#.*$//g' | \
            sed 's/\([a-zA-Z_0-9-]*\)\s*=/\"\1\"=/g' | \
            sed 's/=\s*\([a-zA-Z0-9][^}]*\)/=\"\1\"/g' | \
            sed 's/\s*=\s*/:/g' | \
            sed 's/^}/}\n}/g' | \
            sed 's/^\"/{\n\"/g' | \
            sed 's/\"\s*$/\",/g' | \
            grep -v "hsv\s*{" | \
            grep -v "^[^{}\:]*$" | \
            sed 's/}/},/g' | \
            sed 's/\t/    /g' | \
            perl -p0e 's/\n/%NL%/g' | \
            sed 's/{\s*[^\"}]*}/{}/g' | \
            sed 's/\([}\"]\),\s*%NL%\(\s*\)}/\1%NL%\2}/g' | \
            sed 's/\([}\"]\),\s*%NL%\(\s*\)}/\1%NL%\2}/g' | \
            sed 's/}\s*%NL%\(\s*\)\"/},%NL%\1\"/g' | \
            sed 's/%NL%/ /g' | \
            sed 's/},\s*$/}/g' | \
            jq)
        
        CULTURE_GROUP_ID=$(echo "${CULTURE_FILE_JSON}" | jq -r 'keys[0]')

        #echo "  ### Culture group: ${CULTURE_GROUP_ID}"

        for CULTURE_ID in $(echo "${CULTURE_FILE_JSON}" | \
                                jq ".${CULTURE_GROUP_ID}"'.culture' | \
                                jq 'keys' | \
                                grep "^\s*\"" | \
                                sed 's/^\s*\"\([^\"]*\).*/\1/g'); do

            if ! grep -q '<GameId game="'${GAME_ID}'">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
                echo "      <GameId game=\"${GAME_ID}\">${CULTURE_ID}</GameId>"
            fi
        done
    done 
}

echo "Crusader Kings 3:"            && getCk3Cultures   "CK3"           "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 Apotheosis:" && getCk3Cultures   "CK3Apotheosis" "${CK3Apotheosis_CULTURES_DIR}"
echo "Crusader Kings 3 IBL:"        && getCk3Cultures   "CK3IBL"        "${CK3IBL_CULTURES_DIR}"
echo "Crusader Kings 3 MBP:"        && getCk3Cultures   "CK3MBP"        "${CK3MBP_CULTURES_DIR}"
echo "Crusader Kings 3 SoW:"        && getCk3Cultures   "CK3SoW"        "${CK3SoW_CULTURES_DIR}"
echo "Crusader Kings 3 TFE:"        && getCk3Cultures   "CK3TFE"        "${CK3TFE_CULTURES_DIR}"
echo "Hearts of Iron 4:"            && getHoi4Countries "HOI4"          "${HOI4_TAGS_DIR}" "${HOI4_LOCALISATIONS_DIR}"
echo "Hearts of Iron 4 TGW:"        && getHoi4Countries "HOI4TGW"       "${HOI4TGW_TAGS_DIR}" "${HOI4TGW_LOCALISATIONS_DIR}"
echo "Imperator Rome:"              && getIrCultures    "IR"            "${IR_CULTURES_DIR}"
