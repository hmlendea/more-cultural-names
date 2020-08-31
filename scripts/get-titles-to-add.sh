#!/bin/bash

echo "" > titles-to-add.xml

for TITLE in $(cat ck2.txt | grep "\{" | awk -F= '{print $1}' | sed 's/ //g'); do
    if [ $(grep -c ">"${TITLE}"</GameId" titles.xml) -eq 0 ]; then
        echo "${TITLE} is not defined"
        echo "  <LocationEntity>" >> titles-to-add.xml
        echo "    <Id>${TITLE:2}</Id>" >> titles-to-add.xml
        echo "    <GameIds>" >> titles-to-add.xml
        echo "      <GameId game=\"CK2HIP\" parent=\"\" order=\"\">${TITLE}</GameId>" >> titles-to-add.xml
        echo "    </GameIds>" >> titles-to-add.xml
        echo "  </LocationEntity>" >> titles-to-add.xml
    fi
done
