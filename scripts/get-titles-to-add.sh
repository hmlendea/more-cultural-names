#!/bin/bash

OUTPUT_FILE="titles-to-add.txt"
GAME="CK2"

echo "" > ${OUTPUT_FILE}

for TITLE_ID in $(grep "^\s*[ekdcb]_" ck2mdn.txt | \
                    sed 's/\s*=\s*/ = /g' | \
                    sed 's/^\s*//g' | \
                    awk '{print $1}' | \
                    sort | uniq); do

    LOCATION_ID=${TITLE_ID:2}

    if [ -z "$(grep "<Id>${LOCATION_ID}</Id>" titles.xml)" ] && \
       [ -z "$(grep "<GameId game=\"${GAME}\"[^>]*>${TITLE_ID}<" titles.xml)" ]; then
        echo "    > ${LOCATION_ID} is not defined"

        echo "  <LocationEntity>" >> ${OUTPUT_FILE}
        echo "    <Id>${LOCATION_ID}</Id>" >> ${OUTPUT_FILE}
        echo "    <GameIds>" >> ${OUTPUT_FILE}
        echo "      <GameId game=\"${GAME}\">${TITLE_ID}</GameId>" >> ${OUTPUT_FILE}
        echo "    </GameIds>" >> ${OUTPUT_FILE}
        echo "    <Names>" >> ${OUTPUT_FILE}
        echo "    </Names>" >> ${OUTPUT_FILE}
        echo "  </LocationEntity>" >> ${OUTPUT_FILE}
    fi
done
