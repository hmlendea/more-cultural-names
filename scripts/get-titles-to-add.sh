#!/bin/bash

echo "" > titles-to-add.xml

for TITLE_ID in $(grep "^\s*[ekdcb]_" ../ck2-landed-titles-manager/swmh.txt | \
                    sed 's/\s*=\s*/ = /g' | \
                    sed 's/^\s*//g' | \
                    awk '{print $1}' | \
                    sort | uniq); do
    if [ -z "$(grep "<GameId game=\"CK2HIP\"[^>]*>${TITLE_ID}" titles.xml)" ]; then
        echo "${TITLE_ID} is not defined"
        echo "  <LocationEntity>" >> titles-to-add.xml
        echo "    <Id>${TITLE_ID:2}</Id>" >> titles-to-add.xml
        echo "    <GameIds>" >> titles-to-add.xml
        echo "      <GameId game=\"CK2HIP\" parent=\"\" order=\"\">${TITLE_ID}</GameId>" >> titles-to-add.xml
        echo "    </GameIds>" >> titles-to-add.xml
        echo "    <Names>" >> titles-to-add.xml
        echo "    </Names>" >> titles-to-add.xml
        echo "  </LocationEntity>" >> titles-to-add.xml
    fi
done
