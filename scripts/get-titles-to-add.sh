#!/bin/bash


for TITLE_ID in $(grep "CK3" titles.xml | \
                    sed 's/ *<GameId game=\"CK3\">\([^<]*\)<\/GameId.*/\1/g' | \
                    sort | uniq); do
    if [ ! -z "$(grep "${TITLE_ID} = {" ck2mdn.txt)" ]; then
        echo "${TITLE_ID}"
    fi
done
