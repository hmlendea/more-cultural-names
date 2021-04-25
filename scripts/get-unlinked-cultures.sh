#!/bin/bash
LANGUAGES_FILE="languages.xml"

STEAM_GAMES_DIR="${HOME}/.games/Steam/common"

CK2_CULTURES_DIR="${STEAM_GAMES_DIR}/Crusader Kings II/common/cultures"
CK2HIP_CULTURES_DIR="${HOME}/.paradoxinteractive/Crusader Kings II/mod/Historical_Immersion_Project/common/cultures"
CK3_CULTURES_DIR="${STEAM_GAMES_DIR}/Crusader Kings III/game/common/culture/cultures"

echo "Crusader Kings 2:"
for CULTURE_ID in $(cat "${CK2_CULTURES_DIR}/"* | \
                        grep -P '^\t[a-z]* = {' | \
                        sed 's/^\t*//g' | \
                        awk -F" " '{print $1}' | \
                        sort | uniq); do
    if [ -z "$(grep '<GameId game="CK2">'${CULTURE_ID}'</GameId>' ${LANGUAGES_FILE})" ]; then
        echo "  ${CULTURE_ID}"
    fi
done

echo "Crusader Kings 2 HIP:"
for CULTURE_ID in $(cat "${CK2HIP_CULTURES_DIR}/"* | \
                        grep -P '^\t[a-z]* = {' | \
                        sed 's/^\t*//g' | \
                        awk -F" " '{print $1}' | \
                        sort | uniq); do
    if [ -z "$(grep '<GameId game="CK2HIP">'${CULTURE_ID}'</GameId>' ${LANGUAGES_FILE})" ]; then
        echo "  ${CULTURE_ID}"
    fi
done

echo "Crusader Kings 3:"
for CULTURE_ID in $(cat "${CK3_CULTURES_DIR}/"* | \
                        grep -P '^\t[a-z]* = {' | \
                        sed 's/^\t*//g' | \
                        awk -F" " '{print $1}' | \
                        sort | uniq); do
    if [ -z "$(grep '<GameId game="CK3">'${CULTURE_ID}'</GameId>' ${LANGUAGES_FILE})" ]; then
        echo "  ${CULTURE_ID}"
    fi
done
