#!/bin/bash

FILE="$1"
GAME=$(echo "$2" | tr '[:lower:]' '[:upper:]')

if [ ! -f "${FILE}" ]; then
    echo "The specified file does not exist!"
    exit
fi

FILE_CHARSET=$(file -i "${FILE}" | sed 's/.*charset=\([a-zA-Z0-9-]*\).*/\1/g')

if [ "${FILE_CHARSET}" != "utf-8" ]; then
    iconv -f WINDOWS-1252 -t UTF-8 "${FILE}" > "${FILE}.utf8.temp"
    mv "${FILE}.utf8.temp" "${FILE}"
fi

sed -i 's/\t/    /g' "${FILE}"

if [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ]; then
    sed -i '/[=\">]cn_/d' "${FILE}"
fi

sed -i '/cultural_names\s*=/d' "${FILE}"
# Remove brackets
sed -i 's/=\s*{/=/g' "${FILE}"
sed -i '/^\s*[\{\}]*\s*$/d' "${FILE}"

function remove-empty-titles {
    sed -i 's/\r//g' "${FILE}"
    sed -i 's/^\s*\([ekdcb]_[^\t =]*\)\s*=\s*/\1 =/g' "${FILE}"
    perl -i -p0e 's/\n( *([ekdcb]_[^\t =]*) *= *\n)+ *([ekdcb]_[^\t =]*) *= */\n\3 =/g' "${FILE}"
    sed -i 's/^ \+/      /g' "${FILE}"
}

function replace-cultural-name {
    local CULTURE_ID="$1"
    local LANGUAGE_ID="$2"

    echo "Replacing ${CULTURE_ID} with ${LANGUAGE_ID}"

    sed -i 's/^ *'"${CULTURE_ID}"' *= *\"\([^\"]*\)\"/      <Name language=\"'"${LANGUAGE_ID}"'\" value=\"\1\" \/>/g' "${FILE}"
}

function merge-languages {
    local LANGUAGE_FINAL=${1}
    local LANGUAGE1=${2}
    local LANGUAGE2=${3}

    perl -i -p0e 's/      <Name language=\"'"${LANGUAGE1}"'\" value=\"([^<]*)\" \/>\n *<Name language=\"'"${LANGUAGE2}"'\" value=\"\1\" \/>/      <Name language=\"'"${LANGUAGE_FINAL}"'\" value=\"\1\" \/>/g' "${FILE}"
    perl -i -p0e 's/      <Name language=\"'"${LANGUAGE2}"'\" value=\"([^<]*)\" \/>\n *<Name language=\"'"${LANGUAGE1}"'\" value=\"\1\" \/>/      <Name language=\"'"${LANGUAGE_FINAL}"'\" value=\"\1\" \/>/g' "${FILE}"
}

remove-empty-titles

replace-cultural-name "afghan" "Pashto"
replace-cultural-name "alan" "Alan"
replace-cultural-name "ashkenazi" "Yiddish"
replace-cultural-name "assyrian" "Syriac_Classical"
replace-cultural-name "avar" "Avar_Old"
replace-cultural-name "baloch" "Balochi"
replace-cultural-name "basque" "Basque"
replace-cultural-name "beja" "Beja"
replace-cultural-name "bengali" "Bengali"
replace-cultural-name "bodpa" "Tibetan_Old"
replace-cultural-name "bolghar" "Bulgar"
replace-cultural-name "bosnian" "SerboCroatian"
replace-cultural-name "bulgarian" "Bulgarian"
replace-cultural-name "catalan" "Catalan"
replace-cultural-name "coptic" "Egyptian_Coptic"
replace-cultural-name "croatian" "SerboCroatian"
replace-cultural-name "cuman" "Cuman"
replace-cultural-name "danish" "Danish"
replace-cultural-name "dutch" "Dutch_Middle"
replace-cultural-name "english" "English"
replace-cultural-name "ethiopian" "Amharic"
replace-cultural-name "finnish" "Finnish"
replace-cultural-name "frisian" "Frisian_Old"
replace-cultural-name "georgian" "Georgian_Old"
replace-cultural-name "german" "German_Middle_High"
replace-cultural-name "han" "Chinese_Mandarin"
replace-cultural-name "hungarian" "Hungarian"
replace-cultural-name "ilmenian" "Ilmenian"
replace-cultural-name "irish" "Irish"
replace-cultural-name "karluk" "Karluk"
replace-cultural-name "khanty" "Khanty"
replace-cultural-name "khazar" "Khazar"
replace-cultural-name "khitan" "Khitan"
replace-cultural-name "kirghiz" "Kyrgyz"
replace-cultural-name "komi" "Komi"
replace-cultural-name "kurdish" "Kurdish"
replace-cultural-name "lettigallish" "Latgalian"
replace-cultural-name "lithuanian" "Lithuanian"
replace-cultural-name "marathi" "Marathi"
replace-cultural-name "meshchera" "Meshchera"
replace-cultural-name "mongol" "Mongol_Proto"
replace-cultural-name "mordvin" "Moksha"
replace-cultural-name "nepali" "Nepali"
replace-cultural-name "norman" "Norman"
replace-cultural-name "norse" "Norse"
replace-cultural-name "norwegian" "Norwegian"
replace-cultural-name "nubian" "Nubian_Old"
replace-cultural-name "occitan" "Occitan_Old"
replace-cultural-name "outremer" "French_Old"
replace-cultural-name "pecheneg" "Pecheneg"
replace-cultural-name "pictish" "Pictish"
replace-cultural-name "polish" "Polish"
replace-cultural-name "pommeranian" "Pomeranian"
replace-cultural-name "portuguese" "Portuguese"
replace-cultural-name "prussian" "Prussian_Old"
replace-cultural-name "russian" "Russian"
replace-cultural-name "saka" "Khotanese"
replace-cultural-name "samoyed" "Samoyed"
replace-cultural-name "sardinian" "Sardinian"
replace-cultural-name "serbian" "SerboCroatian"
replace-cultural-name "severian" "Severian"
replace-cultural-name "sinhala" "Sinhala"
replace-cultural-name "sogdian" "Sogdian"
replace-cultural-name "suebi" "Suebi_Medieval"
replace-cultural-name "swedish" "Swedish"
replace-cultural-name "telugu" "Telugu_Old"
replace-cultural-name "tocharian" "Tocharian"
replace-cultural-name "turkish" "Turkish"
replace-cultural-name "uyghur" "Uyghur"
replace-cultural-name "visigothic" "Iberian_Romance"
replace-cultural-name "volhynian" "Volhynian"
replace-cultural-name "welsh" "Welsh"
replace-cultural-name "zaghawa" "Zaghawa"
replace-cultural-name "zhangzhung" "Zhang-Zhung"

if [ "${GAME}" == "CK2" ]; then
    replace-cultural-name "old_frankish" "Frankish"
fi

if [ "${GAME}" == "CK2" ] || [ "${GAME}" == "CK2HIP" ] || [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3MBP" ]; then
    replace-cultural-name "armenian" "Armenian_Middle"
    replace-cultural-name "breton" "Breton_Middle"
    replace-cultural-name "greek" "Greek_Medieval"
    replace-cultural-name "kannada" "Kannada"
    replace-cultural-name "persian" "Persian_Middle"
    replace-cultural-name "roman" "Latin_Medieval"
    replace-cultural-name "tamil" "Tamil_Middle"
fi

if [ "${GAME}" == "CK2" ] || [ "${GAME}" == "CK2HIP" ] || [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3TFE" ]; then
    replace-cultural-name "somali" "Somali"
fi

if [ "${GAME}" == "CK2" ] || [ "${GAME}" == "CK2HIP" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3MBP" ] || [ "${GAME}" == "CK3TFE" ]; then
    replace-cultural-name "carantanian" "Slovene"
fi

if [ "${GAME}" == "CK2" ] || [ "${GAME}" == "CK2HIP" ]; then
    replace-cultural-name "andalusian_arabic" "Arabic"
    replace-cultural-name "arberian" "Arberian"
    replace-cultural-name "bedouin_arabic" "Arabic"
    replace-cultural-name "bohemian" "Czech"
    replace-cultural-name "castillan" "Spanish"
    replace-cultural-name "dalmatian" "Dalmatian_Medieval"
    replace-cultural-name "egyptian_arabic" "Egyptian_Arabic"
    replace-cultural-name "frankish" "French"
    replace-cultural-name "gujurati" "Gujarati_Old"
    replace-cultural-name "lappish" "Sami"
    replace-cultural-name "levantine_arabic" "Arabic"
    replace-cultural-name "maghreb_arabic" "Arabic_Maghreb"
    replace-cultural-name "romanian" "Romanian"
    replace-cultural-name "saxon" "English_Old"
    replace-cultural-name "scottish" "Scottish_Gaelic"
    replace-cultural-name "sephardi" "Ladino"
    replace-cultural-name "slovieni" "Slovak"
    replace-cultural-name "ugricbaltic" "Estonian"
fi

if [ "${GAME}" == "CK2" ] || [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3MBP" ] || [ "${GAME}" == "CK3TFE" ]; then
    replace-cultural-name "old_saxon" "German_Old_Low"
fi

if [ "${GAME}" == "CK2" ] || [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ]; then
    replace-cultural-name "italian" "Tuscan_Medieval"
fi

if [ "${GAME}" == "CK2HIP" ] || [ "${GAME}" == "CK3MBP" ] || [ "${GAME}" == "CK3TFE" ]; then
    replace-cultural-name "gothic" "Gothic"
    replace-cultural-name "thuringian" "Thuringian"
fi

if [ "${GAME}" == "CK2HIP" ]; then
    replace-cultural-name "adhari" "Azeri_Old"
    replace-cultural-name "anglonorse" "English_Old_Norse"
    replace-cultural-name "arpitan" "Arpitan"
    replace-cultural-name "cumbric" "Cumbric"
    replace-cultural-name "hijazi" "Arabic"
    replace-cultural-name "icelandic" "Icelandic"
    replace-cultural-name "italian" "Lombard_Medieval"
    replace-cultural-name "kasogi" "Circassian"
    replace-cultural-name "khalaj" "Khalaj"
    replace-cultural-name "khorasani" "Khorasani_Turkic"
    replace-cultural-name "khwarezmi" "Khwarezmi"
    replace-cultural-name "langobardisch" "Langobardic"
    replace-cultural-name "laziale" "Italian_Central"
    replace-cultural-name "leonese" "Leonese"
    replace-cultural-name "ligurian" "Ligurian"
    replace-cultural-name "livonian" "Livonian"
    replace-cultural-name "low_frankish" "Frankish_Low"
    replace-cultural-name "low_german" "German_Middle_Low"
    replace-cultural-name "low_saxon" "German_Old_Low"
    replace-cultural-name "masmuda" "Masmuda"
    replace-cultural-name "neapolitan" "Neapolitan_Medieval"
    replace-cultural-name "norsegaelic" "Irish_Norse"
    replace-cultural-name "oghuz" "Oghuz"
    replace-cultural-name "pahlavi" "Persian_Middle"
    replace-cultural-name "qufs" "Kufichi"
    replace-cultural-name "sanhaja" "Sanhaja"
    replace-cultural-name "sicilian_arabic" "Arabic"
    replace-cultural-name "szekely" "Hungarian"
    replace-cultural-name "tagelmust" "Tuareg_Tagelmust"
    replace-cultural-name "tajik" "Tajiki"
    replace-cultural-name "tokharian" "Tocharian"
    replace-cultural-name "tuareg" "Tuareg"
    replace-cultural-name "turkmen" "Turkmen_Medieval"
    replace-cultural-name "tuscan" "Tuscan_Medieval"
    replace-cultural-name "udi" "Udi_Middle"
    replace-cultural-name "umbrian" "Umbrian_Medieval"
    replace-cultural-name "venetian" "Venetian_Medieval"
    replace-cultural-name "vepsian" "Vepsian_Medieval"
    replace-cultural-name "yemeni" "Arabic"
    replace-cultural-name "zanata" "Zenati"
fi

if [ "${GAME}" == "CK2HIP" ] || [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3MBP" ] || [ "${GAME}" == "CK3TFE" ]; then
    replace-cultural-name "afar" "Afar"
    replace-cultural-name "aragonese" "Aragonese"
    replace-cultural-name "bashkir" "Bashkir"
    replace-cultural-name "bavarian" "Bavarian_Medieval"
    replace-cultural-name "daylamite" "Daylami"
    replace-cultural-name "franconian" "Frankish"
    replace-cultural-name "galician" "Galician"
    replace-cultural-name "karelian" "Karelian"
    replace-cultural-name "mari" "Mari"
    replace-cultural-name "swabian" "Alemannic_Medieval"
fi

if [ "${GAME}" == "CK2HIP" ] || [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3MBP" ]; then
    replace-cultural-name "cornish" "Cornish_Middle"
fi

if [ "${GAME}" == "CK2HIP" ] || [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ]; then
    replace-cultural-name "sicilian" "Sicilian_Medieval"
    replace-cultural-name "tajik" "Tajiki"
    replace-cultural-name "vepsian" "Vepsian_Medieval"
    replace-cultural-name "yemeni" "Arabic"
fi

if [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3MBP" ] || [ "${GAME}" == "CK3TFE" ]; then
    replace-cultural-name "andalusian" "Arabic"
    replace-cultural-name "anglo_saxon" "English_Old"
    replace-cultural-name "asturleonese" "Leonese"
    replace-cultural-name "bedouin" "Arabic"
    replace-cultural-name "castilian" "Spanish"
    replace-cultural-name "cisalpine" "Lombard_Medieval"
    replace-cultural-name "cumbrian" "Cumbric"
    replace-cultural-name "czech" "Czech"
    replace-cultural-name "egyptian" "Egyptian_Arabic"
    replace-cultural-name "estonian" "Estonian"
    replace-cultural-name "french" "French"
    replace-cultural-name "gaelic" "Scottish_Gaelic"
    replace-cultural-name "latgalian" "Latgalian"
    replace-cultural-name "levantine" "Arabic"
    replace-cultural-name "maghrebi" "Arabic_Maghreb"
    replace-cultural-name "merya" "Merya"
    replace-cultural-name "mogyer" "Hungarian_Old_Early"
    replace-cultural-name "muroma" "Muroma"
    replace-cultural-name "polabian" "Polabian"
    replace-cultural-name "saxon" "German_Middle_Low"
    replace-cultural-name "scottish" "Scots_Early"
    replace-cultural-name "slovien" "Slovak"
    replace-cultural-name "vlach" "Romanian"
fi

if [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3MBP" ]; then
    replace-cultural-name "khwarezmian" "Khwarezmi"
    replace-cultural-name "lombard" "Langobardic"
fi

if [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ] || [ "${GAME}" == "CK3TFE" ]; then
    replace-cultural-name "burmese" "Burmese"
    replace-cultural-name "tsangpa" "Tibetan_Old"
fi

if [ "${GAME}" == "CK3" ] || [ "${GAME}" == "CK3IBL" ]; then
    replace-cultural-name "akan" "Akan"
    replace-cultural-name "baranis" "Berber_Baranis"
    replace-cultural-name "butr" "Berber_Butr"
    replace-cultural-name "chuvash" "Chuvash"
    replace-cultural-name "ewe" "Ewe"
    replace-cultural-name "gujarati" "Gujarati_Old"
    replace-cultural-name "igbo" "Igbo"
    replace-cultural-name "sami" "Sami"
    replace-cultural-name "yughur" "Uyghur_Yellow"

    # Blacklisted for now
    sed -i '/^ *\(frankish\) *=.*$/d' "${FILE}"
fi

if [ "${GAME}" == "CK3MBP" ]; then
    replace-cultural-name "sorbian" "Sorbian"
fi

if [ "${GAME}" == "CK3TFE" ]; then
    replace-cultural-name "abkhazian" "Abkhaz"
    replace-cultural-name "african_romance" "Latin_Late"
    replace-cultural-name "alamannic" "Alemannic_Medieval"
    replace-cultural-name "angle" "Germanic_Proto"
    replace-cultural-name "aquitanian" "Occitan_Old"
    replace-cultural-name "aramean" "Aramaic_Middle"
    replace-cultural-name "armenian" "Armenian_Classical"
    replace-cultural-name "asturian" "Asturian"
    replace-cultural-name "bastarnian" "Germanic_Proto"
    replace-cultural-name "breton" "Breton_Old"
    replace-cultural-name "briton" "Brittonic"
    replace-cultural-name "burgundian" "Germanic_Proto"
    replace-cultural-name "carpian" "Dacian"
    replace-cultural-name "cornish" "Cornish_Old"
    replace-cultural-name "dacian" "Dacian"
    replace-cultural-name "gaul" "Gaulish"
    replace-cultural-name "gepid" "Germanic_Proto"
    replace-cultural-name "greek" "Greek_Before10Century"
    replace-cultural-name "herulian" "Germanic_Proto"
    replace-cultural-name "jewish" "Hejazi_Old"
    replace-cultural-name "kannada" "Kannada_Old"
    replace-cultural-name "kwarezmian" "Khwarezmi"
    replace-cultural-name "langobardi" "Langobardic"
    replace-cultural-name "libian" "Arabic"
    replace-cultural-name "marcomannic" "Suebi_Medieval"
    replace-cultural-name "noric" "Celtic_Noric"
    replace-cultural-name "parthian" "Parthian"
    replace-cultural-name "persian" "Persian_Middle"
    replace-cultural-name "phrygian" "Greek_Ancient_Antigonid"
    replace-cultural-name "rhaetian" "Rhaetic"
    replace-cultural-name "roman" "Latin_Late"
    replace-cultural-name "romano_briton" "Latin_Late"
    replace-cultural-name "romano_dacian" "Latin_Late"
    replace-cultural-name "Romano_Gallic" "Latin_Late"
    replace-cultural-name "romano_iberian" "Latin_Late"
    replace-cultural-name "romano_illyrian" "Latin_Late"
    replace-cultural-name "romano_thracian" "Latin_Late"
    replace-cultural-name "rugian" "Germanic_Proto"
    replace-cultural-name "sclavenian" "Slavic_East_Old"
    replace-cultural-name "suabian" "Alemannic_Medieval"
    replace-cultural-name "tamil" "Tamil_Old"
    replace-cultural-name "thracian" "Thracian"
    replace-cultural-name "vandal" "Germanic_Proto"
    replace-cultural-name "venedian" "Sorbian"
fi

sed -i 's/> \+/>/g' "${FILE}"
sed -i 's/ \+<\//<\//g' "${FILE}"

# Combine arabic names
sed -i '/.*_Arabic.*/d' "${FILE}"
sed -i '/.*Arabic_.*/d' "${FILE}"

merge-languages "Berber" "Berber" "Sanhaja"
merge-languages "Berber" "Berber" "Zenaga"
merge-languages "Berber" "Berber" "Zenati"
merge-languages "Berber" "Tuareg" "Tuareg_Tagelmust"
merge-languages "Berber" "Tuareg" "Zenati"
merge-languages "Berber" "Berber" "Masmuda"
merge-languages "Berber" "Sanhaja" "Masmuda"
merge-languages "Berber" "Berber" "Berber"

merge-languages "French" "French" "Norman"
merge-languages "French" "French" "Arpitan"

merge-languages "Greek_Medieval" "Greek_Medieval" "Gothic_Crimean"

merge-languages "Avar_Old" "Avar_Old" "Bashkir"
merge-languages "Avar_Old" "Avar_Old" "Bulgar"
merge-languages "Cuman" "Cuman" "Avar_Old"
merge-languages "Pecheneg" "Pecheneg" "Oghuz"
merge-languages "Turkish" "Turkish" "Turkmen_Medieval"
merge-languages "Turkish" "Turkish" "Pecheneg"
merge-languages "Turkish" "Turkish" "Oghuz"

merge-languages "English_Old" "English_Old" "English_Old_Norse"
merge-languages "English_Middle" "English_Middle" "English_Old"
merge-languages "English_Middle" "English_Middle" "English_Old_Norse"

merge-languages "Italian_Central" "Italian_Central" "Langobardic"
merge-languages "Italian_Central" "Italian_Central" "Ligurian"
merge-languages "Italian_Central" "Italian_Central" "Lombard_Medieval"
merge-languages "Italian_Central" "Italian_Central" "Neapolitan_Medieval"
merge-languages "Sicilian_Medieval" "Sicilian_Medieval" "Sardinian"
merge-languages "Sicilian_Medieval" "Sicilian" "Sardinian"
merge-languages "Tuscan_Medieval" "Tuscan_Medieval" "Sicilian"
merge-languages "Tuscan_Medieval" "Tuscan_Medieval" "Umbrian_Medieval"
merge-languages "Tuscan_Medieval" "Tuscan_Medieval" "Venetian_Medieval"
merge-languages "Italian" "Italian_Central" "Dalmatian_Medieval"
merge-languages "Italian" "Italian" "Tuscan_Medieval"

merge-languages "Alemannic_Medieval" "Alemannic_Medieval" "Thuringian"
merge-languages "Bavarian_Medieval" "Bavarian_Medieval" "Frankish"
merge-languages "Bavarian_Medieval" "Bavarian_Medieval" "Alemannic_Medieval"
merge-languages "Bavarian_Medieval" "Bavarian_Medieval" "Thuringian"
merge-languages "German_Old_Low" "German_Old_Low" "Alemannic_Medieval"
merge-languages "German_Middle_Low" "German_Middle_Low" "German_Old_Low"
merge-languages "German_Middle_Low" "German_Middle_Low" "Dutch_Middle"
merge-languages "German_Middle_Low" "German_Middle_Low" "Frankish_Low"
merge-languages "German_Middle_High" "German_Middle_High" "Bavarian_Medieval"
merge-languages "German_Middle_High" "German_Middle_High" "German_Middle_Low"
merge-languages "German_Middle_High" "German_Middle_High" "German_Old_Low"
merge-languages "German_Middle_High" "German_Middle_High" "Frankish"
merge-languages "German_Middle_High" "German_Middle_High" "Alemannic_Medieval"

merge-languages "Irish" "Irish" "Irish_Norse"
merge-languages "Irish" "Irish" "Scottish_Gaelic"
merge-languages "Irish" "Irish" "Welsh"
merge-languages "Breton_Middle" "Breton_Middle" "Cornish_Middle"
merge-languages "Breton_Middle" "Breton_Middle" "Cumbric"
merge-languages "Welsh" "Welsh" "Breton_Middle"
merge-languages "Scottish_Gaelic" "Scottish_Gaelic" "Welsh"

echo "Removing unknown languages..."
grep " = \"" "${FILE}" | sort | awk '{print    $1}' | uniq
sed -i '/ = \"/d' "${FILE}"

remove-empty-titles

# Remove duplicated languages
perl -i -p0e 's/      <Name language=\"([^\"]*)\" value=\"([^\"]*)\".*\n *<Name language=\"\1\" value=\"\2\".*/      <Name language=\"\1\" value=\"\2\" \/>/g' "${FILE}"

perl -i -p0e 's/ =\n      <Name / =\n    <Names>\n      <Name /g' "${FILE}"
perl -i -p0e 's/\/>\n([ekdcb])/\/>\n    <\/Names>\n\1/g' "${FILE}"

sed -i 's/^ *<Names>/    <Names>/g' "${FILE}"
sed -i 's/^ *<\/Names>/    <\/Names>/g' "${FILE}"
