#!/bin/bash

WIKIDATA_ID="${1}"
WIKIDATA_URL="https://www.wikidata.org/wiki/Special:EntityData/${1}.json"

if [ ! -f "/usr/bin/jq" ]; then
    echo "Missing 'jq'! Please make sure it's present on the system in order to use this script!"
    exit 1
fi

DATA=$(curl -s "${WIKIDATA_URL}")

function normalise-name() {
    echo $* | \
        sed 's/^"\(.*\)"$/\1/g' | \
        awk -F" - " '{print $1}' | \
        awk -F"(" '{print $1}' | \
        awk -F"," '{print $1}' | \
        sed 's/ *$//g' | \
        sed 's/ suyu$//g'
}

function get-raw-name-for-language() {
    LANGUAGE_CODE="${1}"
    RAW_NAME=$(echo "${DATA}" | jq '.entities.'${WIKIDATA_ID}'.labels.'"\""${LANGUAGE_CODE}"\""'.value')
    NORMALISED_NAME=$(normalise-name "${RAW_NAME}")

    echo "${NORMALISED_NAME}"
}

ENGLISH_NAME=$(get-raw-name-for-language "en")

function get-name-for-language() {
    LANGUAGE_ID="${1}"
    LANGUAGE_CODE="${2}"
    NAME=$(get-raw-name-for-language "${LANGUAGE_CODE}")

    if [ -z "${NAME}" ] ||  [ "${NAME}" == "null" ]; then
        return
    fi

    if [ "${LANGUAGE_CODE}" != "en" ] && [ "${NAME}" == "${ENGLISH_NAME}" ]; then
        return
    fi

    echo "      <Name language=\"${LANGUAGE_ID}\" value=\"${NAME}\" />"
}

function get-names() {
    get-name-for-language "Acehnese" "ace"
    get-name-for-language "Afrikaans" "af"
    get-name-for-language "Albanian" "sq"
    get-name-for-language "Alemannic" "gsw"
    get-name-for-language "Aragonese" "an"
    get-name-for-language "Aromanian" "rup"
    get-name-for-language "Arpitan" "frp"
    get-name-for-language "Asturian" "ast"
    get-name-for-language "Aymara" "ay"
    get-name-for-language "Azeri" "az"
    get-name-for-language "Balinese" "ban"
    get-name-for-language "Basque" "eu"
    get-name-for-language "Bavarian" "bar"
    get-name-for-language "Bikol_Central" "bcl"
    get-name-for-language "Bisalma" "bi"
    get-name-for-language "Breton" "br"
    get-name-for-language "Catalan" "ca"
    get-name-for-language "Cebuano" "ceb"
    get-name-for-language "Cheyenne" "chy"
    get-name-for-language "Chinese_Hakka" "hak"
    get-name-for-language "Chinese_Min_Eastern" "cdo"
    get-name-for-language "Chinese_Min_South" "nan"
    get-name-for-language "Cornish" "kw"
    get-name-for-language "Croatian" "hr"
    get-name-for-language "Czech" "cs"
    get-name-for-language "Danish" "da"
    get-name-for-language "Dimli" "diq"
    get-name-for-language "Dutch" "nl"
    get-name-for-language "Emilian_Romagnol" "eml"
    get-name-for-language "English_Old" "ang"
    get-name-for-language "English" "en"
    get-name-for-language "Esperanto" "eo"
    get-name-for-language "Estonian" "et"
    get-name-for-language "Extremaduran" "ext"
    get-name-for-language "Faroese" "fo"
    get-name-for-language "Finnish" "fi"
    get-name-for-language "French" "fr"
    get-name-for-language "Frisian_East" "stq"
    get-name-for-language "Frisian_North" "frr"
    get-name-for-language "Frisian_West" "fy"
    get-name-for-language "Gagauz" "gag"
    get-name-for-language "Galician" "gl"
    get-name-for-language "German_Low" "nds"
    get-name-for-language "German_Palatine" "pfl"
    get-name-for-language "German_Pennsylvania" "pdc"
    get-name-for-language "German" "de"
    get-name-for-language "Greenlandic" "kl"
    get-name-for-language "Guarani" "gn"
    get-name-for-language "Guianese_French" "gcr"
    get-name-for-language "Haitian" "ht"
    get-name-for-language "Hungarian" "hu"
    get-name-for-language "Icelandic" "is"
    get-name-for-language "Ido" "io"
    get-name-for-language "Igbo" "ig"
    get-name-for-language "Ilocano" "ilo"
    get-name-for-language "Indonesian" "id"
    get-name-for-language "Interlingua" "ia"
    get-name-for-language "Interlingue" "ie"
    get-name-for-language "Irish" "ga"
    get-name-for-language "Italian" "it"
    get-name-for-language "Jamaican" "jam"
    get-name-for-language "Javanese" "jv"
    get-name-for-language "Kabyle" "kab"
    get-name-for-language "Kapampangan" "pam"
    get-name-for-language "Karakalpak" "kaa"
    get-name-for-language "Kazakh" "kk-latn"
    get-name-for-language "Kichwa_Chimboraazo" "qug"
    get-name-for-language "Kinyarwanda" "rw"
    get-name-for-language "Konkani_Goa" "goa"
    get-name-for-language "Kurdish" "ku"
    get-name-for-language "Ladin" "lld"
    get-name-for-language "Ladino" "lad"
    get-name-for-language "Latgalian" "ltg"
    get-name-for-language "Latin" "la"
    get-name-for-language "Latvian" "lv"
    get-name-for-language "Ligurian" "lij"
    get-name-for-language "Limburgish" "li"
    get-name-for-language "Lingala" "ln"
    get-name-for-language "Lingua_Franca_Nova" "lfn"
    get-name-for-language "Lithuanian" "lt"
    get-name-for-language "Livvi" "olo"
    get-name-for-language "Lojban" "jbo"
    get-name-for-language "Lombard" "lmo"
    get-name-for-language "Luxembourgish" "lb"
    get-name-for-language "Madurese" "mad"
    get-name-for-language "Malagasy" "mg"
    get-name-for-language "Malay" "ms"
    get-name-for-language "Maltese" "mt"
    get-name-for-language "Manx" "gv"
    get-name-for-language "Maori" "mi"
    get-name-for-language "Norman" "nrm"
    get-name-for-language "Norwegian" "nb"
    get-name-for-language "Norwegian_Nynorsk" "nn"
    get-name-for-language "Novial" "nov"
    get-name-for-language "Occitan" "oc"
    get-name-for-language "Oromo" "om"
    get-name-for-language "Papiamento" "pap"
    get-name-for-language "Picard" "pcd"
    get-name-for-language "Piemontese" "pms"
    get-name-for-language "Pitkern" "pih"
    get-name-for-language "Polish" "pl"
    get-name-for-language "Portuguese" "pt"

    PORTUGUESE_NAME=$(get-raw-name-for-language "pt")
    PORTUGUESE_BRAZILIAN_NAME=$(get-raw-name-for-language "pt-br")

    if [ -n "${PORTUGUESE_BRAZILIAN_NAME}" ] && [ "${PORTUGUESE_NAME}" != "${PORTUGUESE_BRAZILIAN_NAME}" ]; then
        get-name-for-language "Portuguese_Brazilian" "pt-br"
    fi

    get-name-for-language "Quechua" "qu"
    get-name-for-language "Romanian" "ro"
    get-name-for-language "Romansh" "rm"
    get-name-for-language "Sakizaya" "szy"
    get-name-for-language "Sami_Inari" "smn"
    get-name-for-language "Sami_North" "se"
    get-name-for-language "Sami_Skolt" "sms"
    get-name-for-language "Samoan" "sm"
    get-name-for-language "Samogitian" "sgs"
    get-name-for-language "Sardinian" "sc"
    get-name-for-language "Scots" "sco"
    get-name-for-language "Scottish_Gaelic" "gd"
    get-name-for-language "Serbian" "sr-el"
    get-name-for-language "SerboCroatian" "sh"
    get-name-for-language "Shona" "sn"
    get-name-for-language "Sicilian" "scn"
    get-name-for-language "Silesian" "szl"
    get-name-for-language "Slovak" "sk"
    get-name-for-language "Slovene" "sl"
    get-name-for-language "Somali" "so"
    get-name-for-language "Sorbian_Lower" "dsb"
    get-name-for-language "Sorbian_Upper" "hsb"
    get-name-for-language "Spanish" "es"
    get-name-for-language "Sundanese" "su"
    get-name-for-language "Surinamese" "srn"
    get-name-for-language "Swahili" "sw"
    get-name-for-language "Swedish" "sv"
    get-name-for-language "Tagalog" "tl"
    get-name-for-language "Tatar_Crimean" "crh-latn"
    get-name-for-language "Tetum" "tet"
    get-name-for-language "Tok_Pisin" "tpi"
    get-name-for-language "Turkish" "tr"
    get-name-for-language "Turkmen" "tk"
    get-name-for-language "Uzbek" "uz"
    get-name-for-language "Venetian" "vec"
    get-name-for-language "Vepsian" "vep"
    get-name-for-language "Vietnamese" "vi"
    get-name-for-language "Volapuk" "vo"
    get-name-for-language "Voro" "vro"
    get-name-for-language "Walloon" "wa"
    get-name-for-language "Waray" "war"
    get-name-for-language "Welsh" "cy"
    get-name-for-language "Wolof" "wo"
    get-name-for-language "Yoruba" "yo"
    get-name-for-language "Zeelandic" "zea"
    get-name-for-language "Zhuang" "za"
    get-name-for-language "Zulu" "zu"
}

function get-location-entry() {
    NAMES="$(get-names)"

    [ -z "${NAMES}" ] && return

    LOCATION_ID=$(echo "${ENGLISH_NAME}" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/ /_/g' | sed "s/\'//g" | \
        iconv -f utf8 -t ascii//TRANSLIT)

    echo "  <LocationEntity>"
    echo "    <Id>${LOCATION_ID}</Id>"
    echo "    <WikidataId>${WIKIDATA_ID}</WikidataId>"
    echo "    <GameIds>"
    echo "    </GameIds>"
    echo "    <Names>"
    get-names
    echo "    </Names>"
    echo "  </LocationEntity>"
}

echo ""
get-location-entry
