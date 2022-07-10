#!/bin/bash
source "scripts/common/paths.sh"

function getCk2Cultures() {
    local GAME_ID="${1}" && shift
    local CULTURES_DIR="${*}"

    for CULTURE_ID in $(grep -Pa '^\s[a-z_]* = {' "${CULTURES_DIR}/"*.txt | \
                        grep -va "\(alternate_start\|graphical_cultures\|hip_culture\|mercenary_names\)" | \
                        awk -F":" '{print $2}' | \
                        sed 's/^\s*//g' | \
                        awk -F" " '{print $1}' | \
                        sort | uniq); do
        if ! grep -q "<GameId game=\"${GAME_ID}\">${CULTURE_ID}</GameId>" "${LANGUAGES_FILE}"; then
            echo "  ${CULTURE_ID}"
        fi
    done | sort | uniq
}

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
    done | sort | uniq
}

function getCk3Cultures() {
    local GAME_ID="${1}" && shift

    for CULTURES_DIR in "${@}"; do
        for CULTURE_ID in $(grep -P '^\s*name_list\s*=' "${CULTURES_DIR}/"*.txt | \
                            awk -F"=" '{print $2}' | \
                            sed 's/\s//g' | \
                            sed 's/#.*//g' | \
                            sed 's/^name_list_//g' | \
                            sort | uniq); do
            if ! grep -q '<GameId game="'${GAME_ID}'">'${CULTURE_ID}'</GameId>' "${LANGUAGES_FILE}"; then
                echo "  ${CULTURE_ID}"
            fi
        done
    done | sort | uniq
}

function getHoi4Countries() {
    local GAME_ID="${1}"
    local TAGS_DIR="${2}"
    local LOCALISATIONS_DIR="${3}"
    local COUNTRY_NAME=""

    for TAG in $(cat "${TAGS_DIR}/"*.txt | awk -F"=" '{print $1}' | sed 's/\s*//g' | sort | uniq | grep -v "^#"); do
        COUNTRY_NAME=$(grep "^\s*${TAG}:[0-9]*" "${LOCALISATIONS_DIR}/"*_english.yml | awk -F"\"" '{print $2}' | sed 's/^\([^\"]*\).*/\1/g' | head -n 1)

        for TYPE in "DEF" "democratic" "neutrality" "fascism" "communism"; do
            [ -n "${COUNTRY_NAME}" ] && break
            COUNTRY_NAME=$(grep "^\s*${TAG}_${TYPE}:[0-9]*" "${LOCALISATIONS_DIR}/"*_english.yml | awk -F"\"" '{print $2}' | sed 's/^\([^\"]*\).*/\1/g' | head -n 1)
        done

        if [ -z "${COUNTRY_NAME}" ]; then
            COUNTRY_NAME=$(grep "^\s*${TAG}_democratic:[0-9]*" "${LOCALISATIONS_DIR}/"*_english.yml | awk -F"\"" '{print $2}' | sed 's/^\([^\"]*\).*/\1/g' | head -n 1)
        fi

        if [ -z "${COUNTRY_NAME}" ] && [ "${LOCALISATIONS_DIR}" != "${HOI4_LOCALISATIONS_DIR}" ]; then
            COUNTRY_NAME=$(grep "^\s*${TAG}:[0-9]*" "${HOI4_LOCALISATIONS_DIR}/"*_english.yml | awk -F"\"" '{print $2}' | sed 's/^\([^\"]*\).*/\1/g' | head -n 1)
        fi
        if ! grep -q '<GameId game="'${GAME_ID}'">'${TAG}'</GameId>' "${LANGUAGES_FILE}"; then
            printf "      <GameId game=\"${GAME_ID}\">${TAG}</GameId>"
            [ -n "${COUNTRY_NAME}" ] && printf " <!-- ${COUNTRY_NAME} -->"
            printf "\n"
        fi
    done | sort | uniq
}

function getIrCultures() {
    local GAME_ID="${1}" && shift
    local CULTURES_DIR="${*}"
    local CULTURE_FILE_JSON=""
    local CULTURE_GROUP_ID=""

    for CULTURE_FILE_NAME in $(find "${CULTURES_DIR}" -name "*.txt"); do
        [ $(wc -l "${CULTURE_FILE_NAME}" | awk '{print $1}') -le 2 ] && continue

        CULTURE_FILE_JSON=$(sed 's/\r*//g' "${CULTURE_FILE_NAME}" | \
            sed '1s/^\xEF\xBB\xBF//' | \
            sed 's/#.*$//g' | \
            sed 's/\([a-zA-Z_0-9-]*\)\s*=/\"\1\"=/g' | \
            sed 's/=\s*\([a-zA-Z0-9][^}]*\)/=\"\1\"/g' | \
            sed 's/\s*=\s*/:/g' | \
            sed 's/\"\s*$/\",/g' | \
            grep -v "hsv\s*{" | \
            grep -v "^[^{}\:]*$" | \
            sed 's/}/},/g' | \
            sed 's/\t/    /g' | \
            sed '1 i {' | \
            sed -e '$a}' | \
            perl -p0e 's/\n/%NL%/g' | \
            sed 's/\"rgb\s*{\s*\([0-9][0-9]*\s\s*[0-9][0-9]*\s\s*[0-9][0-9]*\)\s*\"}/\"rgb {\1}\"/g' | \
            sed 's/{\s*[^\"}]*}/{}/g' | \
            sed 's/\([}\"]\),\s*%NL%\(\s*\)}/\1%NL%\2}/g' | \
            sed 's/\([}\"]\),\s*%NL%\(\s*\)}/\1%NL%\2}/g' | \
            sed 's/}\s*%NL%\(\s*\)\"/},%NL%\1\"/g' | \
            sed 's/%NL%/ /g' | \
            sed 's/},\s*$/}/g' | \
            sed 's/\s\s*/ /g' |
            jq)

        for CULTURE_GROUP_ID in $(jq -r 'keys' <<< "${CULTURE_FILE_JSON}" | \
                                    grep "\"" | \
                                    sed \
                                        -e 's/^\s*//' \
                                        -e 's/[,\"]//g'); do
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
    done | sort | uniq
}

echo "Crusader Kings 2:"        && getCk2Cultures       "CK2"       "${CK2_CULTURES_DIR}"
echo "Crusader Kings 2 HIP:"    && getCk2Cultures       "CK2HIP"    "${CK2HIP_CULTURES_DIR}"
echo "Crusader Kings 2 TWK:"    && getCk2Cultures       "CK2TWK"    "${CK2TWK_CULTURES_DIR}"
echo "Crusader Kings 3:"        && getCk3Cultures       "CK3"       "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 AE:"     && getCk3Cultures       "CK3AE"     "${CK3AE_CULTURES_DIR}" "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 ATHA:"   && getCk3Cultures       "CK3ATHA"   "${CK3ATHA_CULTURES_DIR}"
echo "Crusader Kings 3 CE:"     && getCk3Cultures       "CK3CE"     "${CK3CE_CULTURES_DIR}" "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 CMH:"    && getCk3Cultures       "CK3CMH"    "${CK3AP_CULTURES_DIR}" "${CK3IBL_CULTURES_DIR}" "${CK3RICE_CULTURES_DIR}" "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 IBL:"    && getCk3Cultures       "CK3IBL"    "${CK3IBL_CULTURES_DIR}" "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 MBP:"    && getCk3Cultures       "CK3MBP"    "${CK3MBP_CULTURES_DIR}" "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 SoW:"    && getCk3Cultures       "CK3SoW"    "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 TBA:"    && getCk3v14Cultures    "CK3TBA"    "${CK3TBA_CULTURES_DIR}"
echo "Crusader Kings 3 TFE:"    && getCk3Cultures       "CK3TFE"    "${CK3TFE_CULTURES_DIR}"
echo "Hearts of Iron 4:"        && getHoi4Countries     "HOI4"      "${HOI4_TAGS_DIR}" "${HOI4_LOCALISATIONS_DIR}"
echo "Hearts of Iron 4 MDM:"    && getHoi4Countries     "HOI4MDM"   "${HOI4MDM_TAGS_DIR}" "${HOI4MDM_LOCALISATIONS_DIR}"
echo "Hearts of Iron 4 TGW:"    && getHoi4Countries     "HOI4TGW"   "${HOI4TGW_TAGS_DIR}" "${HOI4TGW_LOCALISATIONS_DIR}"
echo "Imperator Rome:"          && getIrCultures        "IR"        "${IR_CULTURES_DIR}"
echo "Imperator Rome ABW:"      && getIrCultures        "IR_ABW"    "${IR_ABW_CULTURES_DIR}"
echo "Imperator Rome AoE:"      && getIrCultures        "IR_AoE"    "${IR_AoE_CULTURES_DIR}"
echo "Imperator Rome INV:"      && getIrCultures        "IR_INV"    "${IR_INV_CULTURES_DIR}"
echo "Imperator Rome TBA:"      && getIrCultures        "IR_TBA"    "${IR_TBA_CULTURES_DIR}"
