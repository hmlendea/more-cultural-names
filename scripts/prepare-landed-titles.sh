#!/bin/bash

FILE="$1"
GAME="$2"

if [ ! -f "${FILE}" ]; then
    echo "The specified file does not exist!"
    exit
fi

sed -i 's/\t/    /g' "${FILE}"


function replace-cultural-name {
    CULTURE_ID="$1"
    LANGUAGE_ID="$2"

    echo "Replacing ${CULTURE_ID} with ${LANGUAGE_ID}"

    sed -i 's/^ *'"${CULTURE_ID}"' *= *\"\([^\"]*\)\"/      <Name language=\"'"${LANGUAGE_ID}"'\">\1<\/Name>/g' "${FILE}"
}

replace-cultural-name "alan" "Alan"
replace-cultural-name "armenian" "Armenian_Middle"
replace-cultural-name "ashkenazi" "Yiddish"
replace-cultural-name "assyrian" "Syriac_Classical"
replace-cultural-name "avar" "Avar_Old"
replace-cultural-name "baloch" "baloch"
replace-cultural-name "basque" "Basque"
replace-cultural-name "bodpa" "Tibetan_Old"
replace-cultural-name "bolghar" "Bulgar"
replace-cultural-name "bosnian" "Bosnian_Medieval"
replace-cultural-name "breton" "Breton_Middle"
replace-cultural-name "coptic" "Egyptian_Coptic"
replace-cultural-name "cuman" "Cuman"
replace-cultural-name "english" "English_Middle"
replace-cultural-name "finnish" "Finnish"
replace-cultural-name "frisian" "Frisian_Old"
replace-cultural-name "georgian" "Georgian"
replace-cultural-name "han" "Chinese_Middle"
replace-cultural-name "hungarian" "Hungarian_Old"
replace-cultural-name "irish" "Irish_Middle"
replace-cultural-name "khanty" "Khanty"
replace-cultural-name "khazar" "Khazar"
replace-cultural-name "khitan" "Khitan"
replace-cultural-name "kirghiz" "Kyrgyz"
replace-cultural-name "komi" "Komi"
replace-cultural-name "kurdish" "Kurdish"
replace-cultural-name "lettigallish" "Latgalian"
replace-cultural-name "lithuanian" "Lithuanian_Medieval"
replace-cultural-name "mongol" "Mongol_Proto"
replace-cultural-name "mordvin" "Moksha"
replace-cultural-name "norman" "Norman"
replace-cultural-name "pecheneg" "Pecheneg"
replace-cultural-name "persian" "Persian"
replace-cultural-name "pictish" "Pictish"
replace-cultural-name "prussian" "Prussian_Old"

if [ "${GAME}" == "CK2" ]; then
    replace-cultural-name "italian" "Tuscan_Medieval"
    replace-cultural-name "old_frankish" "Frankish"
fi

if [ "${GAME}" == "CK2" ] || [ "${GAME}" == "CK2HIP" ]; then
    replace-cultural-name "andalusian_arabic" "Arabic_Andalusia"
    replace-cultural-name "arberian" "arberian"
    replace-cultural-name "bedouin_arabic" "Arabic_Bedouin"
    replace-cultural-name "bohemian" "Czech_Medieval"
    replace-cultural-name "bulgarian" "Bulgarian_Old"
    replace-cultural-name "carantanian" "Slovene_Medieval"
    replace-cultural-name "castillan" "Castillan_Medieval"
    replace-cultural-name "catalan" "Catalan_Medieval"
    replace-cultural-name "crimean_gothic" "Gothic_Crimean"
    replace-cultural-name "croatian" "Croatian_Medieval"
    replace-cultural-name "dalmatian" "Dalmatian_Medieval"
    replace-cultural-name "danish" "Danish_Middle"
    replace-cultural-name "dutch" "Dutch_Middle"
    replace-cultural-name "egyptian_arabic" "Egyptian_Arabic"
    replace-cultural-name "frankish" "French_Old"
    replace-cultural-name "german" "German_Middle_High"
    replace-cultural-name "greek" "Greek_Medieval"
    replace-cultural-name "lappish" "Sami"
    replace-cultural-name "levantine_arabic" "Arabic_Levant"
    replace-cultural-name "maghreb_arabic" "Arabic_Maghreb"
    replace-cultural-name "norse" "Norse"
    replace-cultural-name "norwegian" "Norwegian_Old"
    replace-cultural-name "occitan" "Occitan_Old"
    replace-cultural-name "old_saxon" "German_Old_Low"
    replace-cultural-name "polish" "Polish_Old"
    replace-cultural-name "pommeranian" "Sorbian"
    replace-cultural-name "portuguese" "Portuguese"
    replace-cultural-name "roman" "Latin_Medieval"
    replace-cultural-name "romanian" "Romanian_Old"
    replace-cultural-name "russian" "Russian_Medieval"
    replace-cultural-name "saka" "Khotanese"
    replace-cultural-name "samoyed" "Samoyed"
    replace-cultural-name "sardinian" "Sardinian"
    replace-cultural-name "saxon" "English_Old"
    replace-cultural-name "scottish" "Scottish_Gaelic"
    replace-cultural-name "sephardi" "sephardi"
    replace-cultural-name "serbian" "Serbian_Medieval"
    replace-cultural-name "slovieni" "Slovak_Medieval"
    replace-cultural-name "sogdian" "Sogdian"
    replace-cultural-name "swedish" "Swedish_Old"
    replace-cultural-name "turkish" "Turkish_Old"
    replace-cultural-name "ugricbaltic" "Estonian"
    replace-cultural-name "uyghur" "Uyghur"
    replace-cultural-name "welsh" "Welsh_Middle"
fi

if [ "${GAME}" == "CK2" ] || [ "${GAME}" == "CK3" ]; then
    replace-cultural-name "ilmenian" "Russian_Medieval_Ilmenian"
    replace-cultural-name "meshchera" "Meshchera"
    replace-cultural-name "outremer" "French_Outremer"
    replace-cultural-name "severian" "Russian_Medieval_Severian"
    replace-cultural-name "visigothic" "Gothic_Visigoth"
    replace-cultural-name "volhynian" "Russian_Medieval_Volhynian"
fi

if [ "${GAME}" == "CK3" ]; then
    replace-cultural-name "merya" "Merya"
    replace-cultural-name "muroma" "Muroma"
    replace-cultural-name "sami" "Sami"
fi

sed -i '/^\s*\}*\s*$/d' "${FILE}"
