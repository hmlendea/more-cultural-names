#!/bin/bash

LANDED_TITLES_FILE="ck2mdn.txt"
LOCATIONS_FILE="locations.xml"
GAME="CK3"

for TITLE_ID in $(grep "${GAME}" "${LOCATIONS_FILE}" | \
                    sed 's/ *<GameId game=\"'"${GAME}"'\">\([^<]*\)<\/GameId.*/\1/g' | \
                    sort | uniq); do
    if [ ! -z "$(grep "${TITLE_ID} = {" ${LANDED_TITLES_FILE})" ]; then
        echo "${TITLE_ID}"
    fi
done
