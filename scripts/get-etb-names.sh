#!/bin/bash

ETB_FILE="etb.csv"
LOCATIONS_FILE="locations.xml"

function get-name() {
    TITLE_ID="${1}"
    LANGUAGE="${2}"
    COLUMN_INDEX="${3}"

    NAME=$(cat "${ETB_FILE}" | grep ",${TITLE_ID}," | awk -F, '{print $'${COLUMN_INDEX}'}')

    if [ -n "${NAME// }" ] && \
       [ $(grep "<Name language=\"${LANGUAGE}\"" "${LOCATIONS_FILE}" | grep -c "${NAME}") -eq 0 ]; then
        echo "${NAME}"
    fi
}

function print-name() {
    LANGUAGE="${1}"
    NAME="${2}"

    if [ -n "${NAME}" ]; then
        echo "      <Name language=\"${LANGUAGE}\" value=\"${NAME}\" />"
    fi
}

for TITLE_ID in $(grep "<GameId game=\"CK3\"" "${LOCATIONS_FILE}" | \
                    sed 's/[^>]*>\([^<]*\)<.*/\1/g' | \
                    sort | uniq); do

    BASQUE_NAME=$(get-name ${TITLE_ID} "Basque" 19)
    BRETON_NAME=$(get-name ${TITLE_ID} "Breton_Middle" 11)
    CASTILIAN_NAME=$(get-name ${TITLE_ID} "Castilian_Old" 20)
    CATALAN_NAME=$(get-name ${TITLE_ID} "Catalan_Medieval" 21)
    DANISH_NAME=$(get-name ${TITLE_ID} "Danish_Middle" 31)
    ESTONIAN_NAME=$(get-name ${TITLE_ID} "Estonian" 34)
    FINNISH_NAME=$(get-name ${TITLE_ID} "Finnish" 32)
    GALICIAN_NAME=$(get-name ${TITLE_ID} "Galician" 24)
    GREEK_NAME=$(get-name ${TITLE_ID} "Greek_Medieval" 63)
    IBERIAN_ROMANCE_NAME=$(get-name ${TITLE_ID} "Iberian_Romance" 23)
    LATIN_NAME=$(get-name ${TITLE_ID} "Latin_Classical" 71)
    NORMAN_NAME=$(get-name ${TITLE_ID} "Norman" 16)
    NORSE_NAME=$(get-name ${TITLE_ID} "Norse" 28)
    NORWEGIAN_NAME=$(get-name ${TITLE_ID} "Norwegian_Old" 30)
    OCCITAN_NAME=$(get-name ${TITLE_ID} "Occitan_Old" 17)
    PORTUGUESE_NAME=$(get-name ${TITLE_ID} "Portuguese_Old" 22)
    SAMI_NAME=$(get-name ${TITLE_ID} "Sami" 33)
    SARDINIAN_NAME=$(get-name ${TITLE_ID} "Sardinian" 73)
    SICILIAN_NAME=$(get-name ${TITLE_ID} "Sicilian" 73)
    SWEDISH_NAME=$(get-name ${TITLE_ID} "Swedish_Old" 29)
    WELSH_NAME=$(get-name ${TITLE_ID} "Welsh_Middle" 10)

    if [ -n "${BASQUE_NAME}" ] || \
       [ -n "${BRETON_NAME}" ] || \
       [ -n "${CASTILIAN_NAME}" ] || \
       [ -n "${CATALAN_NAME}" ] || \
       [ -n "${DANISH_NAME}" ] || \
       [ -n "${ESTONIAN_NAME}" ] || \
       [ -n "${FINNISH_NAME}" ] || \
       [ -n "${GALICIAN_NAME}" ] || \
       [ -n "${GREEK_NAME}" ] || \
       [ -n "${IBERIAN_ROMANCE_NAME}" ] || \
       [ -n "${LATIN_NAME}" ] || \
       [ -n "${NORMAN_NAME}" ] || \
       [ -n "${NORSE_NAME}" ] || \
       [ -n "${NORWEGIAN_NAME}" ] || \
       [ -n "${OCCITAN_NAME}" ] || \
       [ -n "${PORTUGUESE_NAME}" ] || \
       [ -n "${SAMI_NAME}" ] || \
       [ -n "${SARDINIAN_NAME}" ] || \
       [ -n "${SICILIAN_NAME}" ] || \
       [ -n "${SWEDISH_NAME}" ] || \
       [ -n "${WELSH_NAME}" ]; then
        echo ${TITLE_ID}

        echo "    <Names>"
        print-name "Basque" "${BASQUE_NAME}"
        print-name "Breton_Middle" "${BRETON_NAME}"
        print-name "Castilian_Old" "${CASTILIAN_NAME}"
        print-name "Catalan_Medieval" "${CATALAN_NAME}"
        print-name "Danish_Middle" "${DANISH_NAME}"
        print-name "Estonian" "${ESTONIAN_NAME}"
        print-name "Finnish" "${FINNISH_NAME}"
        print-name "Galician" "${GALICIAN_NAME}"
        print-name "Greek_Medieval" "${GREEK_NAME}"
        print-name "Iberian_Romance" "${IBERIAN_ROMANCE_NAME}"
        print-name "Latin_Classical" "${LATIN_NAME}"
        print-name "Norman" "${NORMAN_NAME}"
        print-name "Norse" "${NORSE_NAME}"
        print-name "Norwegian_Old" "${NORWEGIAN_NAME}"
        print-name "Occitan_Old" "${OCCITAN_NAME}"
        print-name "Portuguese_Old" "${PORTUGUESE_NAME}"
        print-name "Sami" "${SAMI_NAME}"
        print-name "Sardinian" "${SARDINIAN_NAME}"
        print-name "Sicilian" "${SICILIAN_NAME}"
        print-name "Swedish_Old" "${SWEDISH_NAME}"
        print-name "Welsh_Middle" "${WELSH_NAME}"
        echo "    </Names>"
    fi
done
