#!/bin/bash
LANGUAGES_FILE="languages.xml"

STEAM_APPS_DIR="${HOME}/.local/share/Steam/steamapps"
STEAM_GAMES_DIR="${STEAM_APPS_DIR}/common"
STEAM_WORKSHOP_DIR="${STEAM_APPS_DIR}/workshop"

CK2_CULTURES_DIR="${STEAM_GAMES_DIR}/Crusader Kings II/common/cultures"
CK2HIP_CULTURES_DIR="${HOME}/.paradoxinteractive/Crusader Kings II/mod/Historical_Immersion_Project/common/cultures"
CK3_CULTURES_DIR="${STEAM_GAMES_DIR}/Crusader Kings III/game/common/culture/cultures"
CK3IBL_CULTURES_DIR="${STEAM_WORKSHOP_DIR}/content/1158310/2416949291/common/culture/cultures"
CK3MBP_CULTURES_DIR="${STEAM_WORKSHOP_DIR}/content/1158310/2216670956/common/culture/cultures"

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

function getCk3Cultures() {
    GAME_ID="${1}" && shift
    CULTURES_DIR="${@}"

    for CULTURE_ID in $(cat "${CULTURES_DIR}/"* | \
                            grep -P '^\t[a-z]* = {' | \
                            sed 's/^\t*//g' | \
                            awk -F" " '{print $1}' | \
                            sort | uniq); do
        if [ -z "$(grep '<GameId game="'${GAME_ID}'">'${CULTURE_ID}'</GameId>' ${LANGUAGES_FILE})" ]; then
            echo "  ${CULTURE_ID}"
        fi
    done 
}

echo "Crusader Kings 3:"        && getCk3Cultures "CK3" "${CK3_CULTURES_DIR}"
echo "Crusader Kings 3 IBL:"    && getCk3Cultures "CK3IBL" "${CK3IBL_CULTURES_DIR}"
echo "Crusader Kings 3 MBP:"    && getCk3Cultures "CK3MBP" "${CK3MBP_CULTURES_DIR}"
