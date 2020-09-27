#!/bin/bash

OUTPUT_FILE="titles-to-add.txt"
GAME="ImperatorRome"
GAME2="CK3"

echo "" > ${OUTPUT_FILE}

for TITLE_ID in $(grep "<GameId ga" ir.txt | \
                    sed 's/^ *<GameId game=\"ImperatorRome\">[0-9]*<\/GameId> *//g' | \
                    sed 's/^<!-- //g' | \
                    sed 's/ -->.*$//g' | \
                    sed 's/ /_/g' | \
                    sort | uniq); do
    TITLE_ID=$(echo ${TITLE_ID} | sed 's/_/ /g')
    
    if [ ! -z "$(grep "<Name language=\"Lat[^>]*>${TITLE_ID}<" titles.xml)" ]; then
        echo "    > ${TITLE_ID} is not defined"
        #sed -i 's/^      <GameId game=\"'"${GAME2}"'\">'"${TITLE_ID}"'</      <GameId game=\"CK2\">'"${TITLE_ID}"'<\/GameId>\n      <GameId game=\"'"${GAME2}"'\">'"${TITLE_ID}"'</g' titles.xml
    fi
done
