#!/bin/bash
source "scripts/common/paths.sh"

echo "Crusader Kings 2:"

for CULTURE_ID in $(grep -P '^[\t ][a-z_]* = {' "${CK2_CULTURES_DIR}/"* | \
                    grep -v "\(alternate_start\|graphical_cultures\|mercenary_names\)" | \
                    awk -F":" '{print $2}' | \
                    sed 's/^[\t ]*//g' | \
                    awk -F" " '{print $1}' | \
                    sort | uniq); do
    if ! grep -q '<GameId game="CK2">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
        echo "  ${CULTURE_ID}"
    fi
done

echo "Crusader Kings 2 HIP:"
for CULTURE_ID in $(grep -P '^\s[a-z_]* = {' "${CK2HIP_CULTURES_DIR}/"* | \
                    grep -v "\(alternate_start\|graphical_cultures\|hip_culture\|mercenary_names\)" | \
                    awk -F":" '{print $2}' | \
                    sed 's/^\s*//g' | \
                    awk -F" " '{print $1}' | \
                    sort | uniq); do
    if ! grep -q '<GameId game="CK2HIP">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
        echo "  ${CULTURE_ID}"
    fi
done

function getCk3v14Cultures() {
    local GAME_ID="${1}" && shift
    local CULTURES_DIR="${*}"

    for CULTURE_ID in $(grep -P '^\t[a-z_]* = {' "${CULTURES_DIR}/"*.txt | \
                        grep -v "\(alternate_start\|graphical_cultures\|male_names\|mercenary_names\)" | \
                        awk -F":" '{print $2}' | \
                        sed 's/^\s*//g' | \
                        awk -F" " '{print $1}' | \
                        sort | uniq); do
        if ! grep -q '<GameId game="'${GAME_ID}'">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
            echo "  ${CULTURE_ID}"
        fi
    done 
}

function getCk3Cultures() {
    local GAME_ID="${1}" && shift
    local CULTURES_DIR="${*}"

    for CULTURE_ID in $(grep -P '^[A-Za-z_]* = {' "${CULTURES_DIR}/"*.txt | \
                        awk -F":" '{print $2}' | \
                        sed 's/\s//g' | \
                        awk -F"=" '{print $1}' | \
                        sort | uniq); do
        if ! grep -q '<GameId game="'${GAME_ID}'">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
            echo "  ${CULTURE_ID}"
        fi
    done 
}

function getHoi4Countries() {
    local GAME_ID="${1}"
    local TAGS_DIR="${2}"
    local LOCALISATIONS_DIR="${3}"
    local COUNTRY_NAME=""

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
    local GAME_ID="${1}" && shift
    local CULTURES_DIR="${*}"
    local CULTURE_FILE_JSON=""
    local CULTURE_GROUP_ID=""

    for CULTURE_FILE_NAME in $(find "${CULTURES_DIR}" -name "*.txt"); do
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

echo "Crusader Kings 3:"        && getCk3Cultures       "CK3"       "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 ATHA:"   && getCk3Cultures       "CK3ATHA"   "${CK3ATHA_CULTURES_DIR}"
echo "Crusader Kings 3 IBL:"    && getCk3Cultures       "CK3IBL"    "${CK3IBL_CULTURES_DIR}"
echo "Crusader Kings 3 MBP:"    && getCk3Cultures       "CK3MBP"    "${CK3MBP_CULTURES_DIR}"
echo "Crusader Kings 3 TFE:"    && getCk3v14Cultures    "CK3TFE"    "${CK3TFE_CULTURES_DIR}"
echo "Hearts of Iron 4:"        && getHoi4Countries     "HOI4"      "${HOI4_TAGS_DIR}" "${HOI4_LOCALISATIONS_DIR}"
echo "Hearts of Iron 4 TGW:"    && getHoi4Countries     "HOI4TGW"   "${HOI4TGW_TAGS_DIR}" "${HOI4TGW_LOCALISATIONS_DIR}"
echo "Imperator Rome:"          && getIrCultures        "IR"        "${IR_CULTURES_DIR}"
echo "Imperator Rome:"          && getIrCultures        "IR_AoE"    "${IR_AoE_CULTURES_DIR}"
