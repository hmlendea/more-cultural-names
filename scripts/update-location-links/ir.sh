#!/bin/bash

STEAM_APPS_DIR="${HOME}/.local/share/Steam/steamapps"
STEAM_GAMES_DIR="${STEAM_APPS_DIR}/common"

LOCATIONS_FILE="locations.xml"

function mapNameToLanguage() {
    local CULTURE="${1}"
    local LANGUAGE="${2}"
    
    sed -i 's/^[0-9]*\_'"${CULTURE}"'=\(.*\)/      <Name language=\"'"${LANGUAGE}"'\" value=\"\1\" \/>/g' "${OUTPUT_FILE}"
}

function getProvinces() {
    local GAME="${1}"
    local LOCALISATION_FILE="${2}"
    local OUTPUT_FILE="${3}"

    cat "${LOCALISATION_FILE}" | \
        sed 's/^ *//g' | \
        grep "^PROV" | \
        grep -v "^PROV[0-9]*:[0-9] \"\"" | \
        sed 's/PROV\([^:]*\):[0-9]* *\"\([^\"]*\).*/\1=\2/g' | \
        sed 's/^\([0-9]*\)=/\1_aaa=/g' | \
        sort -n -t "=" | uniq \
        > "${OUTPUT_FILE}"

    for LOCALISED_PROVINCE_ID in $(cat "${LOCATIONS_FILE}" | \
                                            grep "<GameId game=\"${GAME}\"" | \
                                            sed 's/[^>]*>\([^<]*\)/\1/g'); do
        sed -i '/^'"${LOCALISED_PROVINCE_ID}"'[=_]/d' "${OUTPUT_FILE}"
    done

    sed -i 's/^\([0-9]*\)_aaa=\(.*\)/    <\/Names>\n  <\/LocationEntity>\n  <LocationEntity>\n    <Id>\2<\/Id>\n    <GameIds>\n      <GameId game=\"'"${GAME}"'\">\1<\/GameId> <!-- \2 -->\n    <\/GameIds>\n    <Names>/g' "${OUTPUT_FILE}"
    sed -i 's/<Id>\([^<]*\)/<Id>\L\1/g' "${OUTPUT_FILE}"
    sed -i '/<Id>/s/ /_/g' "${OUTPUT_FILE}"
    sed -i 's/^____/    /g' "${OUTPUT_FILE}"

    mapNameToLanguage "aeolian" "Greek_Aeolic"
    mapNameToLanguage "aryan" "Sanskrit_Old"
    mapNameToLanguage "carthaginian" "Punic"
    mapNameToLanguage "east_levantine" "Akkadian"
    mapNameToLanguage "EGY" "Greek_Ancient_Egypt"
    mapNameToLanguage "egyptian" "Egyptian_Late"
    mapNameToLanguage "etruscan" "Etruscan"
    mapNameToLanguage "gallic" "Gaulish"
    mapNameToLanguage "germanic" "Germanic_Proto"
    mapNameToLanguage "hellenic" "Greek_Ancient"
    mapNameToLanguage "iberia" "Iberian"
    mapNameToLanguage "latin" "Latin_Old"
    mapNameToLanguage "lucanian" "Lucanian"
    mapNameToLanguage "massylian" "Massylian"
    mapNameToLanguage "persia" "Persian_Old"
    mapNameToLanguage "phoenician" "Phoenician"
    mapNameToLanguage "PRY" "Greek_Ancient_Antigonid"
    mapNameToLanguage "roman" "Latin_Old"
    mapNameToLanguage "samnite" "Oscan"
    mapNameToLanguage "SEL" "Greek_Ancient_Seleukia"
    mapNameToLanguage "socossian" "Socossian"
    mapNameToLanguage "TRE" "Thracian"
    mapNameToLanguage "umbrian" "Umbrian_Ancient"

    sed -i '1,2d' "${OUTPUT_FILE}"

    printf "    </Names>\n  </LocationEntity>" >> "${OUTPUT_FILE}"

    cat "${OUTPUT_FILE}" | uniq > "${OUTPUT_FILE}.tmp"
    mv "${OUTPUT_FILE}.tmp" "${OUTPUT_FILE}"

    for LOCATION_ID in $(grep "<Id>" "${OUTPUT_FILE}" | sed 's/\s*<Id>\(.*\)<\/Id>.*/\1/g' | sort | uniq); do
        if grep -q "<Id>${LOCATION_ID}</Id>" "${LOCATIONS_FILE}"; then
            echo "    > ${GAME}: ${LOCATION_ID} could potentially be linked"
        fi
    done
}

getProvinces "ImperatorRome"            "${STEAM_GAMES_DIR}/ImperatorRome/game/localization/english/provincenames_l_english.yml"   "ir_provinces.txt"
