#!/bin/bash

echo "" > titles-to-add.xml

for PARENT_ID in $(grep "game=\"CK2HIP\"" titles.xml | \
                    grep -e "parent=\"[^\"]\+\"" | \
                    sed 's/.*parent=\"\([^\"]*\)".*/\1/g' | \
                    sort | uniq); do
    if [ -z "$(grep "<GameId game=\"CK2HIP\"" titles.xml | grep ">"${PARENT_ID}"<")" ]; then
        echo "${PARENT_ID} is not defined"
        echo "  <LocationEntity>" >> titles-to-add.xml
        echo "    <Id>${PARENT_ID:2}</Id>" >> titles-to-add.xml
        echo "    <GameIds>" >> titles-to-add.xml
        echo "      <GameId game=\"CK2HIP\" parent=\"\" order=\"\">${PARENT_ID}</GameId>" >> titles-to-add.xml
        echo "    </GameIds>" >> titles-to-add.xml
        echo "    <Names>" >> titles-to-add.xml
        echo "    </Names>" >> titles-to-add.xml
        echo "  </LocationEntity>" >> titles-to-add.xml
    fi
done
