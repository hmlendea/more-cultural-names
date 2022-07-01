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
    elif [ "${1}" == "--wikidataid" ] || \
         [ "${1}" == "--wikidata" ] || \
         [ "${1}" == "--wdid" ] || \
         [ "${1}" == "--wd" ]; then
        WIKIDATA_ENABLED=true && shift
        WIKIDATA_ID="${1}" && shift
    else
        break
    fi
done

if ${WIKIDATA_ENABLED}; then
    WIKIDATA_ENDPOINT="${WIKIDATA_API_URL}/wiki/Special:EntityData/${WIKIDATA_ID}.json"
    echo "Fetching ${WIKIDATA_ENDPOINT}..."
    WIKIDATA_DATA=$(curl -s "${WIKIDATA_ENDPOINT}")
fi

if ! ${GEONAMES_ENABLED} && ${WIKIDATA_ENABLED}; then
    WIKIDATA_GEONAMES_IDS_COUNT=$(jq '.entities.'"${WIKIDATA_ID}"'.claims.P1566' <<< "${WIKIDATA_DATA}" | grep -c "external-id")

    if [ "${WIKIDATA_GEONAMES_IDS_COUNT}" == "1" ]; then
        GEONAMES_ENABLED=true
        GEONAMES_ID=$(jq '.entities.'"${WIKIDATA_ID}"'.claims.P1566[0].mainsnak.datavalue.value' <<< "${WIKIDATA_DATA}" | sed 's/\"//g')
    else
        GEONAMES_SEARCH_ENDPOINT="${GEONAMES_API_URL}/searchJSON?username=${GEONAMES_USERNAME}&q=${WIKIDATA_ID}"
        echo "Fetching ${GEONAMES_SEARCH_ENDPOINT}..."
        GEONAMES_SEARCH_RESPONSE=$(curl -s "${GEONAMES_SEARCH_ENDPOINT}")
        GEONAMES_SEARCH_RESULTS_COUNT=$(jq '.totalResultsCount' <<< "${GEONAMES_SEARCH_RESPONSE}")

        if [ "${GEONAMES_SEARCH_RESULTS_COUNT}" == "1" ]; then
            GEONAMES_ENABLED=true
            GEONAMES_ID=$(jq '.geonames[0].geonameId' <<< "${GEONAMES_SEARCH_RESPONSE}")
        fi
    fi
fi

if ${GEONAMES_ENABLED}; then
    GEONAMES_ENDPOINT="${GEONAMES_API_URL}/get?username=${GEONAMES_USERNAME}&geonameId=${GEONAMES_ID}"
    echo "Fetching ${GEONAMES_ENDPOINT}..."
    GEONAMES_DATA=$(curl -s "${GEONAMES_ENDPOINT}" | perl -p0e 's/\r*//g' | perl -p0e 's/\n/%NL%/g')
fi

function get-name-from-geonames() {
    local LANGUAGE_CODE="${1}"
    local NAME=""

    echo "${GEONAMES_DATA}" | sed 's/%NL%\s*/\n/g' | \
        grep "<alternateName " | \
        grep "lang=\"${LANGUAGE_CODE}\"" | \
        sed 's/isPreferredName=\"[^\"]*\"\s*//g' | \
        sed 's/\s*<alternateName lang=\"'"${LANGUAGE_CODE}"'\">\([^<]*\).*/\1/g'
}

function get-name-from-wikidata-label() {
    local LANGUAGE_CODE="${1}"

    echo "${WIKIDATA_DATA}" | jq '.entities.'"${WIKIDATA_ID}"'.labels.'"\""${LANGUAGE_CODE}"\""'.value'
}

function get-name-from-wikidata-sitelink() {
    local LANGUAGE_CODE="${1}"
    local SITELINK_TITLE=""
    local NAME=""

    LANGUAGE_CODE="$(echo "${LANGUAGE_CODE}" | sed 's/-/_/g')"
    SITELINK_TITLE=$(echo "${WIKIDATA_DATA}" | jq '.entities.'"${WIKIDATA_ID}"'.sitelinks.'"\""${LANGUAGE_CODE}wiki"\""'.title')

    echo "${SITELINK_TITLE}"
}

function get-name-for-comparison() {
    echo "${@}" | tr '[:upper:]' '[:lower:]'
}

if ${GEONAMES_ENABLED}; then
    echo "Getting the GeoNames default name..."
    GEONAMES_DEFAULT_NAME=$(echo "${GEONAMES_DATA}" | sed 's/%NL%\s*/\n/g' | grep "<name>" | sed 's/\s*<name>\([^<]*\).*/\1/g')
    GEONAMES_DEFAULT_NAME_FOR_COMPARISON="$(echo "${GEONAMES_DEFAULT_NAME}" | tr '[:upper:]' '[:lower:]')"
fi

if ${WIKIDATA_ENABLED}; then
    echo "Getting the WikiData default name..."
    WIKIDATA_DEFAULT_NAME_RAW="$(get-name-from-wikidata-label "en")"
    WIKIDATA_DEFAULT_NAME=$(normalise-name "en" "${WIKIDATA_DEFAULT_NAME_RAW}")
    WIKIDATA_DEFAULT_NAME_FOR_COMPARISON="$(echo "${WIKIDATA_DEFAULT_NAME}" | tr '[:upper:]' '[:lower:]')"
fi

MAIN_DEFAULT_NAME="${WIKIDATA_DEFAULT_NAME}"

[ -z "${MAIN_DEFAULT_NAME}" ] && MAIN_DEFAULT_NAME="${GEONAMES_DEFAULT_NAME}"

function isNameUsable() {
    local LANGUAGE_CODE="${1}"
    local NAME_RAW="${2}"
    local NAME=""
    local NAME_FOR_COMPARISON=""

    NAME=$(normalise-name "${LANGUAGE_CODE}" "${NAME_RAW}")

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

function get-raw-name-for-language() {
    local LANGUAGE_CODE="${1}"
    local NAME=""

    if ${WIKIDATA_ENABLED}; then
        NAME=$(get-name-from-wikidata-label "${LANGUAGE_CODE}")

        if ! isNameUsable "${LANGUAGE_CODE}" "${NAME}"; then
            NAME=$(get-name-from-wikidata-sitelink "${LANGUAGE_CODE}")
        fi
    fi

    if ${GEONAMES_ENABLED}; then
        if ! isNameUsable "${LANGUAGE_CODE}" "${NAME}"; then
            NAME=$(get-name-from-geonames "${LANGUAGE_CODE}")
        fi
    fi

    if ! isNameUsable "${LANGUAGE_CODE}" "${NAME}"; then
        NAME=""
    fi

    echo "${NAME}"
}

function get-name-for-language() {
    local LANGUAGE_CODE="${1}"
    local NAME=""

    NAME=$(get-raw-name-for-language "${LANGUAGE_CODE}")

    [ -z "${NAME}" ] && return

    NAME=$(normalise-name "${LANGUAGE_CODE}" "${NAME}")

    echo "${NAME}"
}

function get-name-line() {
    local LANGUAGE_MCN_ID="${1}"
    local LANGUAGE_CODE="${2}"
    local NAME=""

    NAME=$(get-name-for-language "${LANGUAGE_CODE}")

    [ -n "${NAME}" ] && echo "      <Name language=\"${LANGUAGE_MCN_ID}\" value=\"${NAME}\" />"
}

function get-name-line-2codes() {
    local LANGUAGE_MCN_ID="${1}"
    local LANGUAGE1_CODE="${2}"
    local LANGUAGE2_CODE="${3}"

    local LANGUAGE1_NAME=$(get-name-for-language "${LANGUAGE1_CODE}")
    local LANGUAGE2_NAME_RAW=""
    local LANGUAGE2_NAME=""

    if [ -n "${LANGUAGE1_NAME}" ]; then
        get-name-line "${LANGUAGE_MCN_ID}" "${LANGUAGE1_CODE}"
    else
        if [ "${LANGUAGE1_CODE}" == "grc" ]; then
            LANGUAGE2_NAME_RAW=$(get-raw-name-for-language "${LANGUAGE2_CODE}")
            LANGUAGE2_NAME=$(normalise-name "${LANGUAGE1_CODE}" "${LANGUAGE2_NAME_RAW}")
            [ -n "${LANGUAGE2_NAME}" ] && echo "      <Name language=\"${LANGUAGE_MCN_ID}\" value=\"${LANGUAGE2_NAME}\" />"
        else
            get-name-line "${LANGUAGE_MCN_ID}" "${LANGUAGE2_CODE}"
        fi
    fi
}

function get-name-line-2variants() {
    local LANGUAGE1_MCN_ID="${1}"
    local LANGUAGE1_CODE="${2}"
    local LANGUAGE2_MCN_ID="${3}"
    local LANGUAGE2_CODE="${4}"

    local LANGUAGE1_NAME=""
    local LANGUAGE2_NAME=""

    LANGUAGE1_NAME=$(get-name-for-language "${LANGUAGE1_MCN_ID}" "${LANGUAGE1_CODE}")
    LANGUAGE2_NAME=$(get-name-for-language "${LANGUAGE2_MCN_ID}" "${LANGUAGE2_CODE}")

    if [ -n "${LANGUAGE1_NAME}" ] && [ "${LANGUAGE2_NAME}" != "${LANGUAGE1_NAME}" ]; then
        get-name-line "${LANGUAGE1_MCN_ID}" "${LANGUAGE1_CODE}"
    fi

    get-name-line "${LANGUAGE2_MCN_ID}" "${LANGUAGE2_CODE}"
}

function get_number_of_child_processes() {
    local PID=$$
    local PROCESSES_COUNT=$(ps -eo ppid | grep -w "${PID}" | wc -l)

    echo $((PROCESSES_COUNT-1))
}

function get_name_lines_in_parallel() {
    if [ "$(( $# % 2))" -ne 0 ]; then
        echo "ERROR: Invalid arguments (count: $#) for set_launcher_entries: ${*}" >&2
        exit 1
    fi

    local PAIRS_COUNT=$(($# / 2))
    local GROUP_SIZE=6
    local I=0

    if [ -f "/usr/bin/nproc" ]; then
        GROUP_SIZE=$(nproc)
        GROUP_SIZE=$((GROUP_SIZE*2-2))
    fi

    for I in $(seq 1 ${PAIRS_COUNT}); do
        local LANGUAGE_ID="${1}" && shift
        local LANGUAGE_CODE="${1}" && shift

        while [ "$(get_number_of_child_processes)" -ge "${GROUP_SIZE}" ]; do
            sleep 0.1
        done

        get-name-line "${LANGUAGE_ID}" "${LANGUAGE_CODE}" &
    done

    wait
}

function get-name-lines() {
    get_name_lines_in_parallel \
        "Abkhaz" "ab" \
        "Acehnese" "ace" \
        "Adyghe" "ady" \
        "Afar" "aa" \
        "Afrikaans" "af" \
        "Akan_Twi" "tw" \
        "Akan" "ak" \
        "Albanian_Tosk" "als" \
        "Albanian" "sq" \
        "Alemannic" "gsw" \
        "Arabic_Maghreb" "ary" \
        "Arabic" "ar" \
        "Aragonese" "an" \
        "Armenian_West" "hyw" \
        "Armenian" "hy" \
        "Aromanian" "rup" \
        "Arpitan" "frp" \
        "Asturian" "ast" \
        "Atayal" "tay" \
        "Atikamekw" "atj" \
        "Aymara" "ay" \
        "Azeri" "az" \
        "Balinese" "ban" \
        "Bambara" "bm" \
        "Banjarese" "bjn" \
        "Bashkir" "ba" \
        "Basque" "eu" \
        "Bavarian" "bar" \
        "Belarussian" "be" \
        "Bengali" "bn" \
        "Bikol_Central" "bcl" \
        "Bislama" "bi" \
        "Brahui" "brh" \
        "Breton" "br" \
        "Buginese" "bug" \
        "Bulgarian" "bg" \
        "Catalan" "ca" \
        "Cebuano" "ceb" \
        "Chamorro" "ch" \
        "Chavacano" "cbk-zam" \
        "Chewa" "ny" \
        "Cheyenne" "chy" \
        "Chinese_Hakka" "hak" \
        "Chinese_Min_Eastern" "cdo" \
        "Chinese_Min_South" "nan" \
        "Chuvash" "cv" \
        "Colognian" "ksh" \
        "Cornish" "kw" \
        "Corsican" "co" \
        "Czech" "cs" \
        "Dagbani" "dag" \
        "Danish" "da" \
        "Dinka" "din" \
        "Dutch" "nl" \
        "Egyptian_Arabic" "arz" \
        "Emilian_Romagnol" "eml" \
        "English_Old" "ang" \
        "English" "en" \
        "Esperanto" "eo" \
        "Estonian" "et" \
        "Etruscan" "ett" \
        "Ewe" "ee" \
        "Extremaduran" "ext" \
        "Faroese" "fo" \
        "Fijian_Hindi" "hif" \
        "Fijian" "fj" \
        "Finnish" "fi" \
        "Flemish_West" "vls" \
        "French" "fr" \
        "Frisian_North" "frr" \
        "Frisian_Saterland" "stq" \
        "Frisian_West" "fy" \
        "Friulian" "fur" \
        "Fulah" "ff" \
        "Gagauz" "gag" \
        "Galician" "gl" \
        "Georgian" "ka" \
        "German_Low_Dutch" "nds-nl" \
        "German_Low" "nds" \
        "German_Palatine" "pfl" \
        "German_Pennsylvania" "pdc" \
        "German" "de" \
        "Greek_Ancient_Pontic" "pnt" \
        "Greek" "el" \
        "Greenlandic" "kl" \
        "Guarani" "gn" \
        "Guianese_French" "gcr" \
        "Gujarati" "gu" \
        "Haitian" "ht" \
        "Hausa" "ha" \
        "Hawaiian" "haw" \
        "Hindi" "hi" \
        "Hungarian" "hu" \
        "Icelandic" "is" \
        "Ido" "io" \
        "Igbo" "ig" \
        "Ilocano" "ilo" \
        "Indonesian" "id" \
        "Interlingua" "ia" \
        "Interlingue" "ie" \
        "Inupiaq" "ik" \
        "Inuttitut" "iu" \
        "Irish" "ga" \
        "Italian" "it" \
        "Jamaican" "jam" \
        "Japanese" "ja" \
        "Javanese_Banyumasan" "map-bms" \
        "Javanese" "jv" \
        "Kabiye" "kbp" \
        "Kabuverdianu" "kea" \
        "Kabyle" "kab" \
        "Kannada" "kn" \
        "Kapampangan" "pam" \
        "Karakalpak" "kaa" \
        "Kashubian" "csb" \
        "Kichwa_Chimboraazo" "qug" \
        "Kikuyu" "ki" \
        "Kinyarwanda" "rw" \
        "Kongo" "kg" \
        "Konkani_Goa" "gom-latn" \
        "Korean" "ko" \
        "Kotava" "avk" \
        "Kyrgyz" "ky" \
        "Ladin" "lld" \
        "Ladino" "lad" \
        "Latgalian" "ltg" \
        "Latin" "la" \
        "Latvian" "lv" \
        "Laz" "lzz" \
        "Ligurian" "lij" \
        "Limburgish" "li" \
        "Lingala" "ln" \
        "Lingua_Franca_Nova" "lfn" \
        "Lithuanian" "lt" \
        "Livvi" "olo" \
        "Lojban" "jbo" \
        "Lombard" "lmo" \
        "Luganda" "lg" \
        "Luxembourgish" "lb" \
        "Macedonian_Slavic" "mk" \
        "Madurese" "mad" \
        "Malagasy" "mg" \
        "Malay" "ms" \
        "Maltese" "mt" \
        "Manx" "gv" \
        "Maori" "mi" \
        "Mapuche" "arn" \
        "Marathi" "mr" \
        "Minangkabau" "min" \
        "Mirandese" "mwl" \
        "Mongol" "mn" \
        "Nahuatl" "nah" \
        "Nauru" "na" \
        "Navajo" "nv" \
        "Neapolitan" "nap" \
        "Nias" "nia" \
        "Norman" "nrm" \
        "Novial" "nov" \
        "Occitan" "oc" \
        "Oromo" "om" \
        "Ossetic" "os" \
        "Pangasinan" "pag" \
        "Papiamento" "pap" \
        "Picard" "pcd" \
        "Piemontese" "pms" \
        "Pitkern" "pih" \
        "Plautdietsch" "pdt" \
        "Polish" "pl" \
        "Quechua" "qu" \
        "Romagnol" "rgn" \
        "Romani_Vlax" "rmy" \
        "Romanian" "ro" \
        "Romansh" "rm" \
        "Rundi" "rn" \
        "Russian" "ru" \
        "Sakizaya" "szy" \
        "Sami_Inari" "smn" \
        "Sami_North" "se" \
        "Sami_Skolt" "sms" \
        "Sami_South" "sma" \
        "Samoan" "sm" \
        "Samogitian" "sgs" \
        "Sango" "sg" \
        "Sanskrit" "sa" \
        "Sardinian" "sc" \
        "Scots" "sco" \
        "Scottish_Gaelic" "gd" \
        "Seediq" "trv" \
        "Shilha" "shi" \
        "Shona" "sn" \
        "Sicilian" "scn" \
        "Silesian" "szl" \
        "Sinhala" "si" \
        "Slavonic_Church" "cu" \
        "Slovak" "sk" \
        "Slovene" "sl" \
        "Somali" "so" \
        "Sorbian_Lower" "dsb" \
        "Sorbian_Upper" "hsb" \
        "Sotho" "st" \
        "Sotho_North" "nso" \
        "Spanish" "es" \
        "Sundanese" "su" \
        "Surinamese" "srn" \
        "Swahili" "sw" \
        "Swazi" "ss" \
        "Swedish" "sv" \
        "Tagalog" "tl" \
        "Tahitian" "ty" \
        "Tajiki" "tg-latn" \
        "Tamil" "ta" \
        "Tarantino" "roa-tara" \
        "Tatar_Crimean" "crh-latn" \
        "Tatar" "tt-latn" \
        "Telugu" "te" \
        "Tetum" "tet" \
        "Thai" "th" \
        "Toba_Batak" "bbc" \
        "Tok_Pisin" "tpi" \
        "Tongan" "to" \
        "Tsonga" "ts" \
        "Tswana" "tn" \
        "Turkish" "tr" \
        "Turkmen" "tk" \
        "Udmurt" "udm" \
        "Ukrainian" "uk" \
        "Uzbek" "uz" \
        "Venda" "ve" \
        "Venetian" "vec" \
        "Vepsian" "vep" \
        "Vietnamese" "vi" \
        "Volapuk" "vo" \
        "Voro" "vro" \
        "Walloon" "wa" \
        "Waray" "war" \
        "Welsh" "cy" \
        "Wolof" "wo" \
        "Xhosa" "xh" \
        "Yoruba" "yo" \
        "Zazaki_Dimli" "diq" \
        "Zeelandic" "zea" \
        "Zhuang" "za" \
        "Zulu" "zu" \

    #get-name-line "Hebrew" "he" &
    #get-name-line "Narom" "nrm" &
    get-name-line-2codes "Greek_Ancient" "grc" "el" &
    get-name-line-2codes "Kazakh" "kk-latn" "kk" &
    get-name-line-2variants "Belarussian_Before1933" "be-tarask" "Belarussian" "be" &
    get-name-line-2variants "Bosnian" "bs" "SerboCroatian" "sh" &
    get-name-line-2variants "Chinese" "zh-hans" "Chinese" "zh" &
    get-name-line-2variants "Croatian" "hr" "SerboCroatian" "sh" &
    get-name-line-2variants "Kurdish" "ku" "Kurdish" "ckd" &
    get-name-line-2variants "Norwegian_Nynorsk" "nn" "Norwegian" "nb" &
    get-name-line-2variants "Portuguese_Brazilian" "pt-br" "Portuguese" "pt" &
    get-name-line-2variants "Serbian" "sr-el" "SerboCroatian" "sh" &
    get-name-line-2variants "Serbian" "sr" "SerboCroatian" "sh" &
    wait
}

function get-location-entry() {
    local LOCATION_ID=$(nameToLocationId "${MAIN_DEFAULT_NAME}")

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
