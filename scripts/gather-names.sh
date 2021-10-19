#!/bin/bash

if [ ! -f "/usr/bin/jq" ]; then
    echo "Missing 'jq'! Please make sure it's present on the system in order to use this script!"
    exit 1
fi

source "scripts/common/name_normalisation.sh"

GEONAMES_ENABLED=false
GEONAMES_API_URL="http://api.geonames.org"
GEONAMES_USERNAME="geonamesfreeaccountt"

WIKIDATA_ENABLED=false
WIKIDATA_API_URL="https://www.wikidata.org"

while true; do
    if [ "${1}" == "--geonamesid" ] || \
       [ "${1}" == "--geonames" ] || \
       [ "${1}" == "--gnid" ] || \
       [ "${1}" == "--gn" ]; then
        GEONAMES_ENABLED=true && shift
        GEONAMES_ID="${1}" && shift
        GEONAMES_ENDPOINT="${GEONAMES_API_URL}/get?username=${GEONAMES_USERNAME}&geonameId=${GEONAMES_ID}"
    elif [ "${1}" == "--wikidataid" ] || \
         [ "${1}" == "--wikidata" ] || \
         [ "${1}" == "--wdid" ] || \
         [ "${1}" == "--wd" ]; then
        WIKIDATA_ENABLED=true && shift
        WIKIDATA_ID="${1}" && shift
        WIKIDATA_ENDPOINT="${WIKIDATA_API_URL}/wiki/Special:EntityData/${WIKIDATA_ID}.json"
    else
        break
    fi
done

if ${GEONAMES_ENABLED}; then
    echo "Fetching ${GEONAMES_ENDPOINT}..."
    GEONAMES_DATA=$(curl -s "${GEONAMES_ENDPOINT}" | perl -p0e 's/\r*//g' | perl -p0e 's/\n/%NL%/g')
fi

if ${WIKIDATA_ENABLED}; then
    echo "Fetching ${WIKIDATA_ENDPOINT}..."
    WIKIDATA_DATA=$(curl -s "${WIKIDATA_ENDPOINT}")
fi

function get-name-from-geonames() {
    LANGUAGE_CODE="${1}"

    NAME=$(echo ${GEONAMES_DATA} | sed 's/%NL%\s*/\n/g' | \
        grep "<alternateName " | \
        grep "lang=\"${LANGUAGE_CODE}\"" | \
        sed 's/\s*<alternateName lang=\"'${LANGUAGE_CODE}'\">\([^<]*\).*/\1/g')
    
    NAME=$(normalise-name "${LANGUAGE_CODE}" "${NAME}")

    echo "${NAME}"
}

function get-name-from-wikidata-label() {
    LANGUAGE_CODE="${1}"
    LABEL=$(echo "${WIKIDATA_DATA}" | jq '.entities.'${WIKIDATA_ID}'.labels.'"\""${LANGUAGE_CODE}"\""'.value')
    NAME=$(normalise-name "${LANGUAGE_CODE}" "${LABEL}")

    echo "${NAME}"
}

function get-name-from-wikidata-sitelink() {
    local LANGUAGE_CODE="$(echo "${1}" | sed 's/-/_/g')"
    local SITELINK_TITLE=$(echo "${WIKIDATA_DATA}" | jq '.entities.'${WIKIDATA_ID}'.sitelinks.'"\""${LANGUAGE_CODE}wiki"\""'.title')
    local NAME=$(normalise-name "${LANGUAGE_CODE}" "${SITELINK_TITLE}")

    echo "${NAME}"
}

function get-name-for-comparison() {
    echo "${@}" | tr '[:upper:]' '[:lower:]'
}

if ${GEONAMES_ENABLED}; then
    echo "Getting the GeoNames default name..."
    GEONAMES_DEFAULT_NAME=$(echo ${GEONAMES_DATA} | sed 's/%NL%\s*/\n/g' | grep "<name>" | sed 's/\s*<name>\([^<]*\).*/\1/g')
    GEONAMES_DEFAULT_NAME_FOR_COMPARISON="$(echo "${GEONAMES_DEFAULT_NAME}" | tr '[:upper:]' '[:lower:]')"
fi

if ${WIKIDATA_ENABLED}; then
    echo "Getting the WikiData default name..."
    WIKIDATA_DEFAULT_NAME="$(get-name-from-wikidata-label "en")"
    WIKIDATA_DEFAULT_NAME_FOR_COMPARISON="$(echo "${WIKIDATA_DEFAULT_NAME}" | tr '[:upper:]' '[:lower:]')"
fi

MAIN_DEFAULT_NAME="${WIKIDATA_DEFAULT_NAME}"

[ -z "${MAIN_DEFAULT_NAME}" ] && MAIN_DEFAULT_NAME="${GEONAMES_DEFAULT_NAME}"

function isNameUsable() {
    LANGUAGE_CODE="${1}"
    NAME="${2}"

    if [ -z "${NAME}" ] || [ "${NAME}" == "null" ] || [ "${NAME}" == "Null" ]; then
        return 1 # false
    fi

    NAME_FOR_COMPARISON="$(get-name-for-comparison "${NAME}")"

    if [ "${LANGUAGE_CODE}" != "en" ]; then
        if [ "${NAME_FOR_COMPARISON}" == "${GEONAMES_DEFAULT_NAME_FOR_COMPARISON}" ] ||
           [ "${NAME_FOR_COMPARISON}" == "${GEONAMES_DEFAULT_NAME_FOR_COMPARISON}'" ] ||
           [ "${NAME_FOR_COMPARISON}" == "${WIKIDATA_DEFAULT_NAME_FOR_COMPARISON}" ] ||
           [ "${NAME_FOR_COMPARISON}" == "${WIKIDATA_DEFAULT_NAME_FOR_COMPARISON}'" ]; then
            return 1 # false
        fi
    fi

    return 0 # true
}

function get-name-for-language() {
    local LANGUAGE_CODE="${1}"
    local NAME=""
    
    if ${WIKIDATA_ENABLED}; then
        NAME=$(get-name-from-wikidata-label "${LANGUAGE_CODE}")
        if (! $(isNameUsable "${LANGUAGE_CODE}" "${NAME}")); then
            NAME=$(get-name-from-wikidata-sitelink "${LANGUAGE_CODE}")
        fi
    fi

    if ${GEONAMES_ENABLED}; then
        if (! $(isNameUsable "${LANGUAGE_CODE}" "${NAME}")); then
            NAME=$(get-name-from-geonames "${LANGUAGE_CODE}")
        fi
    fi

    if (! $(isNameUsable "${LANGUAGE_CODE}" "${NAME}")); then
        NAME=""
    fi

    echo "${NAME}"
}

function get-name-line() {
    local LANGUAGE_MCN_ID="${1}"
    local LANGUAGE_CODE="${2}"
    local NAME=$(get-name-for-language "${LANGUAGE_CODE}")

    [ -n "${NAME}" ] && echo "      <Name language=\"${LANGUAGE_MCN_ID}\" value=\"${NAME}\" />"
}

function get-name-line-2codes() {
    LANGUAGE_MCN_ID="${1}"
    LANGUAGE1_CODE="${2}"
    LANGUAGE2_CODE="${3}"

    LANGUAGE1_NAME=$(get-name-for-language "${LANGUAGE1_CODE}")

    if [ -n "${LANGUAGE1_NAME}" ]; then
        get-name-line "${LANGUAGE_MCN_ID}" "${LANGUAGE1_CODE}"
    else
        get-name-line "${LANGUAGE_MCN_ID}" "${LANGUAGE2_CODE}"
    fi
}

function get-name-line-2variants() {
    LANGUAGE1_MCN_ID="${1}"
    LANGUAGE1_CODE="${2}"
    LANGUAGE2_MCN_ID="${3}"
    LANGUAGE2_CODE="${4}"

    LANGUAGE1_NAME=$(get-name-for-language "${LANGUAGE1_MCN_ID}" "${LANGUAGE1_CODE}")
    LANGUAGE2_NAME=$(get-name-for-language "${LANGUAGE2_MCN_ID}" "${LANGUAGE2_CODE}")

    if [ -n "${LANGUAGE1_NAME}" ] && [ "${LANGUAGE2_NAME}" != "${LANGUAGE1_NAME}" ]; then
        get-name-line "${LANGUAGE1_MCN_ID}" "${LANGUAGE1_CODE}"
    fi

    get-name-line "${LANGUAGE2_MCN_ID}" "${LANGUAGE2_CODE}"
}

function get-name-lines() {
    get-name-line "Abkhaz" "ab"
    get-name-line "Acehnese" "ace"
    get-name-line "Adyghe" "ady"
    get-name-line "Afrikaans" "af"
    get-name-line "Akan_Twi" "tw"
    get-name-line "Akan" "ak"
    get-name-line "Albanian" "sq"
    get-name-line "Alemannic" "gsw"
    get-name-line "Arabic" "ar"
    get-name-line "Aragonese" "an"
    get-name-line "Armenian_West" "hyw"
    get-name-line "Armenian" "hy"
    get-name-line "Aromanian" "rup"
    get-name-line "Arpitan" "frp"
    get-name-line "Asturian" "ast"
    get-name-line "Atayal" "tay"
    get-name-line "Atikamekw" "atj"
    get-name-line "Aymara" "ay"
    get-name-line "Azeri" "az"
    get-name-line "Balinese" "ban"
    get-name-line "Bambara" "bm"
    get-name-line "Banjarese" "bjn"
    get-name-line "Bashkir" "ba"
    get-name-line "Basque" "eu"
    get-name-line "Bavarian" "bar"
    get-name-line "Belarussian" "be"
    get-name-line "Bengali" "bn"
    get-name-line "Bikol_Central" "bcl"
    get-name-line "Bislama" "bi"
    get-name-line "Brahui" "brh"
    get-name-line "Breton" "br"
    get-name-line "Buginese" "bug"
    get-name-line "Bulgarian" "bg"
    get-name-line "Catalan" "ca"
    get-name-line "Cebuano" "ceb"
    get-name-line "Chamorro" "ch"
    get-name-line "Chewa" "ny"
    get-name-line "Cheyenne" "chy"
    get-name-line-2variants "Chinese" "zh-hans" "Chinese" "zh"
    get-name-line "Chinese_Hakka" "hak"
    get-name-line "Chinese_Min_Eastern" "cdo"
    get-name-line "Chinese_Min_South" "nan"
    get-name-line "Chuvash" "cv"
    get-name-line "Cornish" "kw"
    get-name-line "Corsican" "co"
    get-name-line "Czech" "cs"
    get-name-line "Danish" "da"
    get-name-line "Dinka" "din"
    get-name-line "Dutch" "nl"
    get-name-line "Emilian_Romagnol" "eml"
    get-name-line "English_Old" "ang"
    get-name-line "English" "en"
    get-name-line "Esperanto" "eo"
    get-name-line "Estonian" "et"
    get-name-line "Ewe" "ee"
    get-name-line "Extremaduran" "ext"
    get-name-line "Faroese" "fo"
    get-name-line "Fijian" "fj"
    get-name-line "Fijian_Hindi" "hif"
    get-name-line "Finnish" "fi"
    get-name-line "Flemish_West" "vls"
    get-name-line "French" "fr"
    get-name-line "Frisian_North" "frr"
    get-name-line "Frisian_Saterland" "stq"
    get-name-line "Frisian_West" "fy"
    get-name-line "Friulian" "fur"
    get-name-line "Fulah" "ff"
    get-name-line "Gagauz" "gag"
    get-name-line "Galician" "gl"
    get-name-line "Georgian" "ka"
    get-name-line "German_Low_Dutch" "nds-nl"
    get-name-line "German_Low" "nds"
    get-name-line "German_Palatine" "pfl"
    get-name-line "German_Pennsylvania" "pdc"
    get-name-line "German" "de"
    get-name-line "Greek" "el"
    get-name-line "Greenlandic" "kl"
    get-name-line "Guarani" "gn"
    get-name-line "Guianese_French" "gcr"
    get-name-line "Gujarati" "gu"
    get-name-line "Haitian" "ht"
    get-name-line "Hausa" "ha"
    get-name-line "Hawaiian" "haw"
    get-name-line "Hebrew" "he"
    get-name-line "Hindi" "hi"
    get-name-line "Hungarian" "hu"
    get-name-line "Icelandic" "is"
    get-name-line "Ido" "io"
    get-name-line "Igbo" "ig"
    get-name-line "Ilocano" "ilo"
    get-name-line "Indonesian" "id"
    get-name-line "Interlingua" "ia"
    get-name-line "Interlingue" "ie"
    get-name-line "Inupiaq" "ik"
    get-name-line "Inuttitut" "iu"
    get-name-line "Irish" "ga"
    get-name-line "Italian" "it"
    get-name-line "Jamaican" "jam"
    get-name-line "Japanese" "ja"
    get-name-line "Javanese" "jv"
    get-name-line "Kabiye" "kbp"
    get-name-line "Kabuverdianu" "kea"
    get-name-line "Kabyle" "kab"
    get-name-line "Kannada" "kn"
    get-name-line "Kapampangan" "pam"
    get-name-line "Karakalpak" "kaa"
    get-name-line "Kashubian" "csb"
    get-name-line "Kichwa_Chimboraazo" "qug"
    get-name-line "Kikuyu" "ki"
    get-name-line "Kinyarwanda" "rw"
    get-name-line "Kongo" "kg"
    get-name-line "Konkani_Goa" "gom-latn"
    get-name-line "Korean" "ko"
    get-name-line "Kotava" "avk"
    get-name-line "Kurdish" "ku"
    get-name-line "Kyrgyz" "ky"
    get-name-line "Ladin" "lld"
    get-name-line "Ladino" "lad"
    get-name-line "Latgalian" "ltg"
    get-name-line "Latin" "la"
    get-name-line "Latvian" "lv"
    get-name-line "Ligurian" "lij"
    get-name-line "Limburgish" "li"
    get-name-line "Lingala" "ln"
    get-name-line "Lingua_Franca_Nova" "lfn"
    get-name-line "Lithuanian" "lt"
    get-name-line "Livvi" "olo"
    get-name-line "Lojban" "jbo"
    get-name-line "Lombard" "lmo"
    get-name-line "Luganda" "lg"
    get-name-line "Luxembourgish" "lb"
    get-name-line "Macedonian_Slavic" "mk"
    get-name-line "Madurese" "mad"
    get-name-line "Malagasy" "mg"
    get-name-line "Malay" "ms"
    get-name-line "Maltese" "mt"
    get-name-line "Manx" "gv"
    get-name-line "Maori" "mi"
    get-name-line "Marathi" "mr"
    get-name-line "Minangkabau" "min"
    get-name-line "Mirandese" "mwl"
    get-name-line "Mongol" "mn"
    get-name-line "Nahuatl" "nah"
    get-name-line "Nauru" "na"
    get-name-line "Navajo" "nv"
    get-name-line "Neapolitan" "nap"
    get-name-line "Norman" "nrm"
    get-name-line "Novial" "nov"
    get-name-line "Occitan" "oc"
    get-name-line "Oromo" "om"
    get-name-line "Ossetic" "os"
    get-name-line "Pangasinan" "pag"
    get-name-line "Papiamento" "pap"
    get-name-line "Picard" "pcd"
    get-name-line "Piemontese" "pms"
    get-name-line "Pitkern" "pih"
    get-name-line "Plautdietsch" "pdt"
    get-name-line-2codes "Kazakh" "kk-latn" "kk"
    get-name-line-2variants "Norwegian_Nynorsk" "nn" "Norwegian" "nb"
    get-name-line "Polish" "pl"
    get-name-line-2variants "Portuguese_Brazilian" "pt-br" "Portuguese" "pt"
    get-name-line "Quechua" "qu"
    get-name-line "Romani_Vlax" "rmy"
    get-name-line "Romanian" "ro"
    get-name-line "Romansh" "rm"
    get-name-line "Rundi" "rn"
    get-name-line "Russian" "ru"
    get-name-line "Sakizaya" "szy"
    get-name-line "Sami_Inari" "smn"
    get-name-line "Sami_North" "se"
    get-name-line "Sami_Skolt" "sms"
    get-name-line "Sami_South" "sma"
    get-name-line "Samoan" "sm"
    get-name-line "Samogitian" "sgs"
    get-name-line "Sango" "sg"
    get-name-line "Sanskrit" "sa"
    get-name-line "Sardinian" "sc"
    get-name-line "Scots" "sco"
    get-name-line "Scottish_Gaelic" "gd"
    get-name-line "Seediq" "trv"
    get-name-line-2variants "Bosnian" "bs" "SerboCroatian" "sh"
    get-name-line-2variants "Croatian" "hr" "SerboCroatian" "sh"
    get-name-line-2variants "Serbian" "sr" "SerboCroatian" "sh"
    get-name-line-2variants "Serbian" "sr-el" "SerboCroatian" "sh"
    get-name-line "Shona" "sn"
    get-name-line "Sicilian" "scn"
    get-name-line "Silesian" "szl"
    get-name-line "Sinhala" "si"
    get-name-line "Slavonic_Church" "cu"
    get-name-line "Slovak" "sk"
    get-name-line "Slovene" "sl"
    get-name-line "Somali" "so"
    get-name-line "Sorbian_Lower" "dsb"
    get-name-line "Sorbian_Upper" "hsb"
    get-name-line "Spanish" "es"
    get-name-line "Sundanese" "su"
    get-name-line "Surinamese" "srn"
    get-name-line "Swahili" "sw"
    get-name-line "Swazi" "ss"
    get-name-line "Swedish" "sv"
    get-name-line "Tagalog" "tl"
    get-name-line "Tahitian" "ty"
    get-name-line "Tajiki" "tg-latn"
    get-name-line "Tamil" "ta"
    get-name-line "Tarantino" "roa-tara"
    get-name-line "Tatar_Crimean" "crh-latn"
    get-name-line "Tatar" "tt-latn"
    get-name-line "Telugu" "te"
    get-name-line "Tetum" "tet"
    get-name-line "Thai" "th"
    get-name-line "Tok_Pisin" "tpi"
    get-name-line "Tongan" "to"
    get-name-line "Tsonga" "ts"
    get-name-line "Turkish" "tr"
    get-name-line "Turkmen" "tk"
    get-name-line "Udmurt" "udm"
    get-name-line "Ukrainian" "uk"
    get-name-line "Uzbek" "uz"
    get-name-line "Venetian" "vec"
    get-name-line "Vepsian" "vep"
    get-name-line "Vietnamese" "vi"
    get-name-line "Volapuk" "vo"
    get-name-line "Voro" "vro"
    get-name-line "Walloon" "wa"
    get-name-line "Waray" "war"
    get-name-line "Welsh" "cy"
    get-name-line "Wolof" "wo"
    get-name-line "Xhosa" "xh"
    get-name-line "Yoruba" "yo"
    get-name-line "Zazaki_Dimli" "diq"
    get-name-line "Zeelandic" "zea"
    get-name-line "Zhuang" "za"
    get-name-line "Zulu" "zu"
}

function get-location-entry() {
    LOCATION_ID=$(echo "${MAIN_DEFAULT_NAME}" | \
        iconv -f utf8 -t ascii//TRANSLIT | \
        sed 's/-le-/_le_/g' | \
        sed 's/ /_/g' | sed "s/\'//g" | \
        sed 's/\(north\|west\|south\|east\)ern/\1/g' | \
        sed 's/^\(north\|west\|south\|east\)_\(.*\)$/\2_\1/g' | \
        tr '[:upper:]' '[:lower:]')

    echo "  <LocationEntity>"
    echo "    <Id>${LOCATION_ID}</Id>"
    ${GEONAMES_ENABLED} && echo "    <GeoNamesId>${GEONAMES_ID}</GeoNamesId>"
    ${WIKIDATA_ENABLED} && echo "    <WikidataId>${WIKIDATA_ID}</WikidataId>"
    echo "    <GameIds>"
    echo "    </GameIds>"
    echo "    <Names>"
    get-name-lines | sort | uniq
    echo "    </Names>"
    echo "  </LocationEntity>"
}

echo "Getting the location entry..."
echo ""

get-location-entry
