#!/bin/bash

HOI4_STATES_DIR=~/".games/Steam/common/Hearts of Iron IV/history/states"
LOCATIONS_FILE="$(pwd)/locations.xml"
PARENTS_FILE="$(pwd)/hoi4_parents.txt"

echo "" > "${PARENTS_FILE}"

cd "${HOI4_STATES_DIR}"

for FILE in *.txt ; do
    STATE_ID=$(echo $FILE | sed 's/^\([0-9]*\)-.*/\1/g')

    PROVINCE_LIST=$(cat "${FILE}" | \
        sed 's/[\{\}]//g' | \
        sed '/^[[:space:]]*$/d' | \
        awk '/provinces/{getline; print}' | \
        sed 's/\r//g' | \
        sed 's/^[\t ]*//g' | \
        sed 's/[\t ]*$//g' | \
        sed 's/[\t ]\+/ /g')

    echo "Getting the provinces for state #${STATE_ID}"

    for PROVINCE_ID in ${PROVINCE_LIST}; do
        [[ -z "${PROVINCE_LIST// }" ]] && continue

        echo "${PROVINCE_ID}=${STATE_ID}" >> "${PARENTS_FILE}"
    done
done

for PROVINCE_ID in $(grep "game=\"HOI4\" type=\"City\"" "${LOCATIONS_FILE}" | \
                    sed 's/^ *<GameId [^>]*>\([0-9]*\)<.*/\1/g' | \
                    sort | uniq); do
    STATE_ID=$(grep "^${PROVINCE_ID}=" "${PARENTS_FILE}" | awk -F = '{print $2}')
    
    echo "Province #${PROVINCE_ID}'s parent set to state #${STATE_ID}"
    sed -i 's/\(^ *<GameId game=\"HOI4\" type=\"City\"\)\( parent=\"[^\"]*\"\)*>'"${PROVINCE_ID}"'</\1 parent=\"'"${STATE_ID}"'\">'"${PROVINCE_ID}"'</g' "${LOCATIONS_FILE}"
done