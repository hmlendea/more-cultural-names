#!/bin/bash

ETB_FILE="etb.csv"
LOCATIONS_FILE="locations.xml"

function get-name() {
    TITLE_ID="${1}"
    COLUMN_INDEX="${2}"
    LANGUAGE1="${3}"
    LANGUAGE2="${4}"
    LANGUAGE3="${5}"
    LANGUAGE4="${6}"
    LANGUAGE5="${7}"
    LANGUAGE6="${8}"

    NAME=$(cat "${ETB_FILE}" | \
            grep ",${TITLE_ID}," | \
            awk -F, '{print $'${COLUMN_INDEX}'}' | \
            awk -F"(" '{print $1}' | \
            sed 's/^ *//g' | sed 's/ *$//g' | \
            sed 's/~//g')

    if [ -n "${NAME// }" ] && \
       [ $(grep "<Name language=\"\(${LANGUAGE1}\|${LANGUAGE2}\|${LANGUAGE3}\|${LANGUAGE4}\|${LANGUAGE5}\|${LANGUAGE6}\)\"" "${LOCATIONS_FILE}" | \
           grep --ignore-case -c "${NAME}") -eq 0 ]; then
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

for TITLE_ID in $(awk -F, '{print $2}' "${ETB_FILE}" | \
                    grep "^[ekdcb]_" | grep "^b_" | \
                    shuf); do

    BASQUE_NAME=$(get-name ${TITLE_ID} 19 "Basque")
    BRETON_NAME=$(get-name ${TITLE_ID} 11 "Breton_Middle")
    BULGARIAN_NAME=$(get-name ${TITLE_ID} 82 "Bulgarian_Old")
    CASTILIAN_NAME=$(get-name ${TITLE_ID} 20 "Castilian_Old" "Castilian" "Spanish")
    CATALAN_NAME=$(get-name ${TITLE_ID} 21 "Catalan_Old" "Catalan")
    CORNISH_NAME=$(get-name ${TITLE_ID} 12 "Cornish_Middle")
    CROATIAN_NAME=$(get-name ${TITLE_ID} 77 "Croatian_Medieval")
    CUMBRIC_NAME=$(get-name ${TITLE_ID} 13 "Cumbric")
    CZECH_NAME=$(get-name ${TITLE_ID} 84 "Czech_Medieval" "Czech")
    DANISH_NAME=$(get-name ${TITLE_ID} 31 "Danish_Middle")
    ENGLISH_MIDDLE_NAME=$(get-name ${TITLE_ID} 5 "English_Middle")
    ENGLISH_OLD_NAME=$(get-name ${TITLE_ID} 6 "English_Old")
    ESTONIAN_NAME=$(get-name ${TITLE_ID} 34 "Estonian")
    FINNISH_NAME=$(get-name ${TITLE_ID} 32 "Finnish" )
    GALICIAN_NAME=$(get-name ${TITLE_ID} 24 "Galician" "Portuguese_Old" "Portuguese")
    GREEK_NAME=$(get-name ${TITLE_ID} 63 "Greek_Medieval")
    HUNGARIAN_OLD_NAME=$(get-name ${TITLE_ID} 88 "Hungarian_Old_Early" )
    HUNGARIAN_NAME=$(get-name ${TITLE_ID} 89 "Hungarian" "Hungarian_Middle" "Hungarian_Old" )
    IBERIAN_ROMANCE_NAME=$(get-name ${TITLE_ID} 23 "Iberian_Romance")
    IRISH_NAME=$(get-name ${TITLE_ID} 3 "Irish_Middle" "Irish")
    ILMENIAN_NAME=$(get-name ${TITLE_ID} 95 "Ilmenian")
    LATIN_NAME=$(get-name ${TITLE_ID} 71 "Latin_Classical" "Latin_Medieval" "Latin" "Latin_Old")
    NORMAN_NAME=$(get-name ${TITLE_ID} 16 "Norman")
    NORSE_NAME=$(get-name ${TITLE_ID} 28 "Norse")
    NORWEGIAN_NAME=$(get-name ${TITLE_ID} 30"Norwegian_Old" )
    OCCITAN_NAME=$(get-name ${TITLE_ID} 17 "Occitan_Old")
    PICTISH_NAME=$(get-name ${TITLE_ID} 9 "Pictish")
    POLABIAN_NAME=$(get-name ${TITLE_ID} 86 "Polabian")
    POLISH_NAME=$(get-name ${TITLE_ID} 85 "Polish_Old" "Polish")
    POMERANIAN_NAME=$(get-name ${TITLE_ID} 83 "Pomeranian")
    PORTUGUESE_NAME=$(get-name ${TITLE_ID} 22 "Portuguese_Old" "Portuguese")
    ROMANIAN_NAME=$(get-name ${TITLE_ID} 80 "Romanian_Old" "Romanian")
    SAMI_NAME=$(get-name ${TITLE_ID} 33 "Sami" )
    SARDINIAN_NAME=$(get-name ${TITLE_ID} 73 "Sardinian" )
    SERBIAN_NAME=$(get-name ${TITLE_ID} 79 "Serbian" "Serbian_Medieval" "Croatian" "Croatian_Medieval" "SerboCroatian" "SerboCroatian_Medieval")
    SEVERIAN_NAME=$(get-name ${TITLE_ID} 96 "Severian")
    SCOTTISH_NAME=$(get-name ${TITLE_ID} 4 "Scottish_Gaelic" "Irish_Middle")
    SICILIAN_NAME=$(get-name ${TITLE_ID} 74 "Sicilian")
    SLOVAK_NAME=$(get-name ${TITLE_ID} 87 "Slovak_Medieval" "Slovak" )
    SWEDISH_NAME=$(get-name ${TITLE_ID} 29 "Swedish_Old")
    TOCHARIAN_NAME=$(get-name ${TITLE_ID} 191 "Tocharian")
    VOLHYNIAN_NAME=$(get-name ${TITLE_ID} 97 "Volhynian")
    WELSH_NAME=$(get-name ${TITLE_ID} 10 "Welsh_Middle" "Welsh")

    if [ -n "${BASQUE_NAME}" ] || \
       [ -n "${BRETON_NAME}" ] || \
       [ -n "${BULGARIAN_NAME}" ] || \
       [ -n "${CASTILIAN_NAME}" ] || \
       [ -n "${CATALAN_NAME}" ] || \
       [ -n "${CORNISH_NAME}" ] || \
       [ -n "${CROATIAN_NAME}" ] || \
       [ -n "${CUMBRIC_NAME}" ] || \
       [ -n "${CZECH_NAME}" ] || \
       [ -n "${DANISH_NAME}" ] || \
       [ -n "${ENGLISH_MIDDLE_NAME}" ] || \
       [ -n "${ENGLISH_OLD_NAME}" ] || \
       [ -n "${ESTONIAN_NAME}" ] || \
       [ -n "${FINNISH_NAME}" ] || \
       [ -n "${GALICIAN_NAME}" ] || \
       [ -n "${GREEK_NAME}" ] || \
       [ -n "${HUNGARIAN_OLD_NAME}" ] || \
       [ -n "${HUNGARIAN_NAME}" ] || \
       [ -n "${IBERIAN_ROMANCE_NAME}" ] || \
       [ -n "${IRISH_NAME}" ] || \
       [ -n "${ILMENIAN_NAME}" ] || \
       [ -n "${LATIN_NAME}" ] || \
       [ -n "${NORMAN_NAME}" ] || \
       [ -n "${NORSE_NAME}" ] || \
       [ -n "${NORWEGIAN_NAME}" ] || \
       [ -n "${OCCITAN_NAME}" ] || \
       [ -n "${PICTISH_NAME}" ] || \
       [ -n "${POLABIAN_NAME}" ] || \
       [ -n "${POLISH_NAME}" ] || \
       [ -n "${POMERANIAN_NAME}" ] || \
       [ -n "${PORTUGUESE_NAME}" ] || \
       [ -n "${ROMANIAN_NAME}" ] || \
       [ -n "${SAMI_NAME}" ] || \
       [ -n "${SARDINIAN_NAME}" ] || \
       [ -n "${SERBIAN_NAME}" ] || \
       [ -n "${SEVERIAN_NAME}" ] || \
       [ -n "${SCOTTISH_NAME}" ] || \
       [ -n "${SICILIAN_NAME}" ] || \
       [ -n "${SLOVAK_NAME}" ] || \
       [ -n "${SWEDISH_NAME}" ] || \
       [ -n "${TOCHARIAN_NAME}" ] || \
       [ -n "${VOLHYNIAN_NAME}" ] || \
       [ -n "${WELSH_NAME}" ]; then
        echo ${TITLE_ID}

        echo "    <Names>"
        print-name "Basque" "${BASQUE_NAME}"
        print-name "Breton_Middle" "${BRETON_NAME}"
        print-name "Bulgarian_Old" "${BULGARIAN_NAME}"
        print-name "Castilian_Old" "${CASTILIAN_NAME}"
        print-name "Catalan_Old" "${CATALAN_NAME}"
        print-name "Cornish_Middle" "${CORNISH_NAME}"
        print-name "Croatian_Medieval" "${CROATIAN_NAME}"
        print-name "Cumbric" "${CUMBRIC_NAME}"
        print-name "Czech_Medieval" "${CZECH_NAME}"
        print-name "Danish_Middle" "${DANISH_NAME}"
        print-name "English_Middle" "${ENGLISH_MIDDLE_NAME}"
        print-name "English_Old" "${ENGLISH_OLD_NAME}"
        print-name "Estonian" "${ESTONIAN_NAME}"
        print-name "Finnish" "${FINNISH_NAME}"
        print-name "Galician" "${GALICIAN_NAME}"
        print-name "Greek_Medieval" "${GREEK_NAME}"
        print-name "Hungarian_Old_Early" "${HUNGARIAN_OLD_NAME}"
        print-name "Hungarian" "${HUNGARIAN_NAME}"
        print-name "Iberian_Romance" "${IBERIAN_ROMANCE_NAME}"
        print-name "Irish_Middle" "${IRISH_NAME}"
        print-name "Ilmenian" "${ILMENIAN_NAME}"
        print-name "Latin_Classical" "${LATIN_NAME}"
        print-name "Norman" "${NORMAN_NAME}"
        print-name "Norse" "${NORSE_NAME}"
        print-name "Norwegian_Old" "${NORWEGIAN_NAME}"
        print-name "Occitan_Old" "${OCCITAN_NAME}"
        print-name "Pictish" "${PICTISH_NAME}"
        print-name "Polabian" "${POLABIAN_NAME}"
        print-name "Polish_Old" "${POLISH_NAME}"
        print-name "Pomeranian" "${POMERANIAN_NAME}"
        print-name "Portuguese_Old" "${PORTUGUESE_NAME}"
        print-name "Romanian_Old" "${ROMANIAN_NAME}"
        print-name "Sami" "${SAMI_NAME}"
        print-name "Sardinian" "${SARDINIAN_NAME}"
        print-name "Serbian_Medieval" "${SERBIAN_NAME}"
        print-name "Severian" "${SEVERIAN_NAME}"
        print-name "Scottish_Gaelic" "${SCOTTISH_NAME}"
        print-name "Sicilian" "${SICILIAN_NAME}"
        print-name "Slovak_Medieval" "${SLOVAK_NAME}"
        print-name "Swedish_Old" "${SWEDISH_NAME}"
        print-name "Tocharian" "${TOCHARIAN_NAME}"
        print-name "Volhynian" "${VOLHYNIAN_NAME}"
        print-name "Welsh_Middle" "${WELSH_NAME}"
        echo "    </Names>"
    fi
done
