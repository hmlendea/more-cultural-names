#!/bin/bash

HOI4_DIR="${HOME}/.local/share/Steam/steamapps/common/Hearts of Iron IV"
HOI4_STATES_DIR="${HOI4_DIR}/history/states"
HOI4_LOCALISATION_DIR="${HOI4_DIR}/localisation/english"
LOCATIONS_FILE="$(pwd)/locations.xml"
PARENTS_FILE="$(pwd)/hoi4_parents.txt"

echo "" > "${PARENTS_FILE}"

for FILE in "${HOI4_STATES_DIR}"/*.txt ; do
    STATE_ID=$(basename "${FILE}" | sed 's/^\([0-9]*\)\s*-\s*.*/\1/g')
    
    PROVINCE_LIST=$(cat "${FILE}" | \
        sed 's/\r//g' | \
        tr '\n' ' ' | \
        sed 's/\s\s*/ /g' | \
        sed 's/.*provinces\s*=\s*{\([^}]*\).*/\1/g' | \
        sed 's/\(^\s*\|\s*$\)//g')

    echo "Getting the provinces for state #${STATE_ID}"

    for PROVINCE_ID in ${PROVINCE_LIST}; do
        [[ -z "${PROVINCE_LIST// }" ]] && continue

        echo "${PROVINCE_ID}=${STATE_ID}" >> "${PARENTS_FILE}"
    done
done

#for CITY_ID in $(cat "${HOI4_LOCALISATION_DIR}/victory_points_l_english.yml" | sed 's/^\s*VICTORY_POINTS_\([0-9]*\).*/\1/g'); do
for CITY_ID in $(grep "game=\"HOI4\" type=\"City\"" "${LOCATIONS_FILE}" | \
                    sed 's/^ *<GameId [^>]*>\([0-9]*\)<.*/\1/g' | \
                    sort -h | uniq); do
    STATE_ID=$(grep "^${CITY_ID}=" "${PARENTS_FILE}" | awk -F = '{print $2}')
    CITY_NAME=$(cat "${HOI4_LOCALISATION_DIR}/victory_points_l_english.yml" | \
                    grep "^\s*VICTORY_POINTS_${CITY_ID}:" | \
                    sed 's/^\s*VICTORY_POINTS_'"${CITY_ID}"':[0-9]\s*\"\([^\"]*\).*/\1/g')

    echo "Province #${CITY_ID}: State=#${STATE_ID} Name='${CITY_NAME}'"
    sed -i 's/\(^\s*<GameId game=\"HOI4\" type=\"City\"\)\( parent=\"[^\"]*\"\)*>'"${CITY_ID}"'<.*/\1 parent=\"'"${STATE_ID}"'\">'"${CITY_ID}"'<\/GameId> <!-- '"${CITY_NAME}"' -->/g' "${LOCATIONS_FILE}"
done
