#!/bin/bash

WIKIDATA_ID="${1}"

WIKIDATA_URL="https://www.wikidata.org/wiki/Special:EntityData/${1}.json"
GREEK_TRANSLITERATION_URL="https://transliterate.com/Home/Transliterate"

if [ ! -f "/usr/bin/jq" ]; then
    echo "Missing 'jq'! Please make sure it's present on the system in order to use this script!"
    exit 1
fi

DATA=$(curl -s "${WIKIDATA_URL}")

function get-translitterationDotCom-transliteration() {
    RAW_NAME="${1}"
    LANGUAGE="${2}"
    SCHEME="${3}"

    curl -s \
        --location 'https://www.translitteration.com/ajax/en/transliterate/' \
        --request POST \
        --form 'text="'"${RAW_NAME}"'"' \
        --form 'tlang="'"${LANGUAGE}"'"' \
        --form 'script="latn"' \
        --form 'scheme="'"${SCHEME}"'"' |
            sed 's/^ack::://g'
}

function transliterate-name() {
    LANGUAGE_CODE="${1}" && shift
    RAW_NAME=$(echo "$*" | sed 's/^"\(.*\)"$/\1/g')
    LATIN_NAME="${RAW_NAME}"

    if [ "${LANGUAGE_CODE}" == "ab" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "abk" "iso-9")
    elif [ "${LANGUAGE_CODE}" == "ady" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "ady" "iso-9")
    elif [ "${LANGUAGE_CODE}" == "ba" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "bak" "iso-9")
    elif [ "${LANGUAGE_CODE}" == "be" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "bel" "national" |
            sed 's/\([a-zA-Z]\)H/\1h/g')
    elif [ "${LANGUAGE_CODE}" == "bg" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "bul" "streamlined" |
            sed 's/\([a-zA-Z]\)H/\1h/g')
    elif [ "${LANGUAGE_CODE}" == "cu" ]; then
        LATIN_NAME=$(curl -s \
            --location 'https://podolak.net/en/transliteration/old-church-slavonic' \
            --request POST \
            --data-urlencode 'quelltext=cu' \
            --data-urlencode 'zieltext=isor9' \
            --data-urlencode 'startabfrage=1' \
            --data-urlencode 'text='"${RAW_NAME}" \
            --data-urlencode 'transliteration=Transliteration' \
            --data-urlencode 'cu_isor9_jer=3' | \
                grep "ausgabe" | \
                sed 's/.*>\(.*\)<\/textarea>.*/\1/g')
    elif [ "${LANGUAGE_CODE}" == "cv" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "chv" "ala-lc" |
            sed 's/i͡/y/g')
    elif [ "${LANGUAGE_CODE}" == "el" ]; then
        LATIN_NAME=$(curl -s \
            --location 'https://transliterate.com/Home/Transliterate' \
            --request POST \
            --form 'input="'"${RAW_NAME}"'"' | jq '.latin' | sed \
                -e 's/^"\(.*\)"$/\1/g' \
                -e 's/^Mp/B/g' \
                -e 's/^Nk/G/g' \
                -e 's/^Nt/D/g' \
                -e 's/mp\([ao]\)/b\1/g' \
                -e 's/nknt/gd/g' \
                -e 's/ntm/dm/g' \
                -e 's/rnk/rk/g' \
                -e 's/snt/sht/g')
    elif [ "${LANGUAGE_CODE}" == "hy" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "xcl" "iso-9985")
    elif [ "${LANGUAGE_CODE}" == "hyw" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "hye" "ala-lc")
    elif [ "${LANGUAGE_CODE}" == "ka" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "kat" "national")
    elif [ "${LANGUAGE_CODE}" == "kk" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "kaz" "national")
    elif [ "${LANGUAGE_CODE}" == "ky" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "kir" "iso-9")
    elif [ "${LANGUAGE_CODE}" == "mk" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "mkd" "bgn-pcgn")
    elif [ "${LANGUAGE_CODE}" == "mn" ]; then
        LATIN_NAME=$(curl -s \
            --location 'https://www.ushuaia.pl/transliterate/transliterate.php' \
            --request POST \
            --header 'Cookie: translit=6tpj46oc8cq7ou4vci78f37rbi; lastlang=mongolian_mns_transliterate;' \
            --header 'Content-Type: application/x-www-form-urlencoded' \
            --data-urlencode 'text='"${RAW_NAME}" \
            --data-urlencode 'lang=mongolian_mns_transliterate')
    elif [ "${LANGUAGE_CODE}" == "os" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "oss" "iso-9")
    elif [ "${LANGUAGE_CODE}" == "ru" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "rus" "bgn-pcgn" |
            sed 's/\([a-zA-Z]\)Y/\1y/g')
    elif [ "${LANGUAGE_CODE}" == "sr" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "srp" "national")
    elif [ "${LANGUAGE_CODE}" == "udm" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "udm" "bgn-pcgn")
    elif [ "${LANGUAGE_CODE}" == "uk" ]; then
        LATIN_NAME=$(get-translitterationDotCom-transliteration "${RAW_NAME}" "ukr" "bgn-pcgn")
    fi

    echo "${LATIN_NAME}"
}

function normalise-name() {
    LANGUAGE_CODE="${1}" && shift
    NAME=$(echo "$*" | sed 's/^"\(.*\)"$/\1/g')

    transliterate-name "${LANGUAGE_CODE}" "${NAME}" | \
        sed 's/^"\(.*\)"$/\1/g' | \
        awk -F" - " '{print $1}' | \
        awk -F"/" '{print $1}' | \
        awk -F"(" '{print $1}' | \
        awk -F"," '{print $1}' | \
        sed \
            -e 's/ *$//g' \
            -e 's/^\(Category\)\://g' \
            -e 's/^\([Gg]e*m[ei]+n*t*[aen]\|Faritan'"'"'i\|[Mm]agaalada\) //g' \
            -e 's/^[KkCc]om*un*[ea] d[eio] //g' \
            -e 's/^\(Category\)\: //g' \
            -e 's/^Lungsod ng //g' \
            \
            -e 's/^\(Byen\|Dinas\|Ìlú\|Mbanza ya\|Sita\|Syudad han\) //g' \
            -e 's/^Co[ou]nt\(ae\|y\) //g' \
            -e 's/^Con[dt][aá]d*[eou] \(d[eo] \)*//g' \
            -e 's/^Comt[aé]t* de //g' \
            -e 's/^[KkCc]om*un*[ea]*[n]* //g' \
            -e 's/^[Pp][’]*r[ao][bpvw][ëií][nñ][t]*[csz]*[eiíjoy]*[aez]* \(d*[eio] \)*//g' \
            -e 's/^Res*publi[ck]a //g' \
            -e 's/^\(Comitatu[ls]\|Emirlando\|Eparchía\|Graafskap\|Graflando\|Hạt\|Hrabství\|Ìpínlẹ̀\|Komēteía\|Kontelezh\|Pasiolak\|Swydd\|ti\|Vilojati\) //g' \
            -e 's/^\(Khu vực\|Jimbo ya\|Lalawigan ng\|Marz\|Mkoa wa\|Talaith\|Tawilayt n\|Tighrmt n\Vostraŭ\||W[iı]lay\(a\|ah\|etê\)\) \(\(de\|ya\) \)*//g' \
            -e 's/^\(Distri[ck]to*\|[Rr]e[gģh]i[oóu]n*i*[aes]*\) \(d[ei] \|of \)*//g' \
            -e 's/[ -]\(Bölgesi\|çayı\|Chê\|Chhī\|Cumhuriyeti\|gielda\|[Gg]overnorate\|Hahoodzo\|jõgi\|Kūn\|linn\|maak[ou]n[dt]a*\|[Mm]ahal[iı]\|[Mm]arz\|megye\|mhuriyeti\|[Mm]in[tţ]a[kq]at*\|[Mm]unicipality\|Nehri\|osariik\|[Rr]egion\|šaary\|síksá\|Sṳ\|suohkan\|suyu\|tamaneɣt\|tartomány\|Town\|vald\|[Vv]il[aā][jy]\(eti\|s\)\)$//g' \
            -e 's/[ -]\([Rr]e[gģh]i[oóu]n*[ei]*[as]*\|sht’at’i\|sritis\)$//g' \
            -e 's/ [Pp][’]*r[ao][bpvw][ëií][nñ][t]*[csz]*[eiíjoy]*[aez]*$//g' \
            -e 's/skaya oblast[’]*$/sk/g' \
            -e 's/as \(vilāj[as]\|mintaka\)$/a/g' \
            -e 's/jas \(grāfiste\|province\)$/ja/g' \
            -e 's/jos \(provincija\)$/ja/g' \
            -e 's/ko \(konderria\|probintzia\)$//g' \
            -e 's/n \(kreivikunta\)$//g' \
            -e 's/o \(emyratas\|grafystė\)$/as/g' \
            -e 's/os \(vilaja\)$/as/g' \
            -e 's/ [Cc]o[ou]nt\(ae\|y\)$//g' \
            -e 's/ [KkCc]om*un*[ea]*$//g' \
            \
            -e 's/^\(Abhainn\|Afon\|Ri[ou]\) //g' \
            -e 's/^\(Ducado\|Reinu\) de l'"\'"'//g' \
            -e 's/^[Dd][eé]part[aei]m[ei]*nt[o]* //g' \
            -e 's/'\''i \(krahvkond\|departemang\)$//g' \
            -e 's/'\''i \(krahvkond\|departemang\)$//g' \
            \
            -e 's/[ -]\(eanangoddi\|ili\|[Ss]én[g]*\|vilayəti\)$//g' \
            \
            -e 's/ amšyn$/ Amšyn/g' \
            -e 's/^biển /Biển /g' \
            -e 's/ d\([əei][nňņ][g]*[eizẓ]*\)$/ D\1/g' \
            -e 's/ zarez’$/ Zarez’/g' \
            -e 's/ çov$/ Çov/g' \
            -e 's/ tinĕsĕ$/ Tinĕsĕ/g' \
            -e 's/ mora$/ Mora/g' \
            -e 's/ itsasoa$/ Itsasoa/g' \
            -e 's/^m\([ae]re*\) /M\1 /g' \
            -e 's/ nord$/ Nord/g' \
            -e 's/ d\([eə]ng*izi\)$/ D\1/g' \
            -e 's/ havet$/ Havet/g' \
            -e 's/ j\([uū]ra\)$/ J\1/g' \
            -e 's/ m\([aeoó][rř]j*[ioe]\)$/ M\1/g' \
            \
            -e 's/^la[cg]o* //g' \
            -e 's/^Llyn //g' \
            \
            -e 's/n-a$/na/g'
}

function capitalise() {
    printf '%s' "$1" | head -c 1 | tr [:lower:] [:upper:]
    printf '%s' "$1" | tail -c '+2'
}

function get-name-from-label() {
    LANGUAGE_CODE="${1}"
    LABEL=$(echo "${DATA}" | jq '.entities.'${WIKIDATA_ID}'.labels.'"\""${LANGUAGE_CODE}"\""'.value')
    NAME=$(normalise-name "${LANGUAGE_CODE}" "${LABEL}")

    echo "${NAME}"
}

function isNameUsable() {
    LANGUAGE_CODE="${1}"
    NAME="${2}"

    if [ -z "${NAME}" ] || [ "${NAME}" == "null" ] || [ "${NAME}" == "Null" ]; then
        return 1 # false
    fi

    NAME_FOR_COMPARISON=$(echo "${NAME}" | tr '[:upper:]' '[:lower:]')

    if [ "${LANGUAGE_CODE}" != "en" ]; then
        if [ "${NAME_FOR_COMPARISON}" == "${ENGLISH_NAME_FOR_COMPARISON}" ] ||
           [ "${NAME_FOR_COMPARISON}" == "${ENGLISH_NAME_FOR_COMPARISON}'" ]; then
            return 1 # false
        fi
    fi

    return 0 # true
}

function get-name-from-sitelink() {
    LANGUAGE_CODE="$(echo "${1}" | sed 's/-/_/g')"
    SITELINK_TITLE=$(echo "${DATA}" | jq '.entities.'${WIKIDATA_ID}'.sitelinks.'"\""${LANGUAGE_CODE}wiki"\""'.title')
    NAME=$(normalise-name "${LANGUAGE_CODE}" "${SITELINK_TITLE}")

    echo "${NAME}"
}

ENGLISH_NAME=$(get-name-from-label "en")
ENGLISH_NAME_FOR_COMPARISON=$(echo "${ENGLISH_NAME}" | tr '[:upper:]' '[:lower:]')

function get-raw-name-for-language() {
    LANGUAGE_CODE="${1}"
    NAME=$(get-name-from-label "${LANGUAGE_CODE}")

    if ! $(isNameUsable "${LANGUAGE_CODE}" "${NAME}"); then
        NAME=$(get-name-from-sitelink "${LANGUAGE_CODE}")
    fi

    if ! $(isNameUsable "${LANGUAGE_CODE}" "${NAME}"); then
        return
    fi

    echo "${NAME}"
}

function get-name-for-language() {
    LANGUAGE_ID="${1}"
    LANGUAGE_CODE="${2}"
    NAME=$(get-raw-name-for-language "${LANGUAGE_CODE}")

    [ -n "${NAME}" ] && echo "      <Name language=\"${LANGUAGE_ID}\" value=\"${NAME}\" />"
}

function get-name-for-language-2codes() {
    LANGUAGE_ID="${1}"
    LANGUAGE1_CODE="${2}"
    LANGUAGE2_CODE="${3}"

    LANGUAGE1_NAME=$(get-raw-name-for-language "${LANGUAGE1_CODE}")

    if [ -n "${LANGUAGE1_NAME}" ]; then
        get-name-for-language "${LANGUAGE_ID}" "${LANGUAGE1_CODE}"
    else
        get-name-for-language "${LANGUAGE_ID}" "${LANGUAGE2_CODE}"
    fi
}

function get-name-for-language-2variants() {
    LANGUAGE1_ID="${1}"
    LANGUAGE1_CODE="${2}"
    LANGUAGE2_ID="${3}"
    LANGUAGE2_CODE="${4}"

    LANGUAGE1_NAME=$(get-raw-name-for-language "${LANGUAGE1_ID}" "${LANGUAGE1_CODE}")
    LANGUAGE2_NAME=$(get-raw-name-for-language "${LANGUAGE2_ID}" "${LANGUAGE2_CODE}")

    if [ -n "${LANGUAGE1_NAME}" ] && [ "${LANGUAGE2_NAME}" != "${LANGUAGE1_NAME}" ]; then
        get-name-for-language "${LANGUAGE1_ID}" "${LANGUAGE1_CODE}"
    fi

    get-name-for-language "${LANGUAGE2_ID}" "${LANGUAGE2_CODE}"
}

function get-names() {
    get-name-for-language "Abkhaz" "ab"
    get-name-for-language "Acehnese" "ace"
    get-name-for-language "Adyghe" "ady"
    get-name-for-language "Afrikaans" "af"
    get-name-for-language "Akan_Twi" "tw"
    get-name-for-language "Akan" "ak"
    get-name-for-language "Albanian" "sq"
    get-name-for-language "Alemannic" "gsw"
    get-name-for-language "Aragonese" "an"
    get-name-for-language "Armenian" "hy"
    get-name-for-language "Armenian_West" "hyw"
    get-name-for-language "Aromanian" "rup"
    get-name-for-language "Arpitan" "frp"
    get-name-for-language "Asturian" "ast"
    get-name-for-language "Atayal" "tay"
    get-name-for-language "Atikamekw" "atj"
    get-name-for-language "Aymara" "ay"
    get-name-for-language "Azeri" "az"
    get-name-for-language "Balinese" "ban"
    get-name-for-language "Bambara" "bm"
    get-name-for-language "Banjarese" "bjn"
    get-name-for-language "Bashkir" "ba"
    get-name-for-language "Basque" "eu"
    get-name-for-language "Bavarian" "bar"
    get-name-for-language "Belarussian" "be"
    get-name-for-language "Bikol_Central" "bcl"
    get-name-for-language "Bislama" "bi"
    get-name-for-language "Breton" "br"
    get-name-for-language "Buginese" "bug"
    get-name-for-language "Bulgarian" "bg"
    get-name-for-language "Catalan" "ca"
    get-name-for-language "Cebuano" "ceb"
    get-name-for-language "Chamorro" "ch"
    get-name-for-language "Chewa" "ny"
    get-name-for-language "Cheyenne" "chy"
    get-name-for-language "Chinese_Hakka" "hak"
    get-name-for-language "Chinese_Min_Eastern" "cdo"
    get-name-for-language "Chinese_Min_South" "nan"
    get-name-for-language "Chuvash" "cv"
    get-name-for-language "Cornish" "kw"
    get-name-for-language "Corsican" "co"
    get-name-for-language "Czech" "cs"
    get-name-for-language "Danish" "da"
    get-name-for-language "Dinka" "din"
    get-name-for-language "Dutch" "nl"
    get-name-for-language "Emilian_Romagnol" "eml"
    get-name-for-language "English_Old" "ang"
    get-name-for-language "English" "en"
    get-name-for-language "Esperanto" "eo"
    get-name-for-language "Estonian" "et"
    get-name-for-language "Ewe" "ee"
    get-name-for-language "Extremaduran" "ext"
    get-name-for-language "Faroese" "fo"
    get-name-for-language "Fijian" "fj"
    get-name-for-language "Fijian_Hindi" "hif"
    get-name-for-language "Finnish" "fi"
    get-name-for-language "Flemish_West" "vls"
    get-name-for-language "French" "fr"
    get-name-for-language "Frisian_North" "frr"
    get-name-for-language "Frisian_Saterland" "stq"
    get-name-for-language "Frisian_West" "fy"
    get-name-for-language "Friulian" "fur"
    get-name-for-language "Fulah" "ff"
    get-name-for-language "Gagauz" "gag"
    get-name-for-language "Galician" "gl"
    get-name-for-language "Georgian" "ka"
    get-name-for-language "German_Low_Dutch" "nds-nl"
    get-name-for-language "German_Low" "nds"
    get-name-for-language "German_Palatine" "pfl"
    get-name-for-language "German_Pennsylvania" "pdc"
    get-name-for-language "German" "de"
    get-name-for-language "Greek" "el"
    get-name-for-language "Greenlandic" "kl"
    get-name-for-language "Guarani" "gn"
    get-name-for-language "Guianese_French" "gcr"
    get-name-for-language "Haitian" "ht"
    get-name-for-language "Hausa" "ha"
    get-name-for-language "Hawaiian" "haw"
    get-name-for-language "Hungarian" "hu"
    get-name-for-language "Icelandic" "is"
    get-name-for-language "Ido" "io"
    get-name-for-language "Igbo" "ig"
    get-name-for-language "Ilocano" "ilo"
    get-name-for-language "Indonesian" "id"
    get-name-for-language "Interlingua" "ia"
    get-name-for-language "Interlingue" "ie"
    get-name-for-language "Inupiaq" "ik"
    get-name-for-language "Irish" "ga"
    get-name-for-language "Italian" "it"
    get-name-for-language "Jamaican" "jam"
    get-name-for-language "Javanese" "jv"
    get-name-for-language "Kabiye" "kbp"
    get-name-for-language "Kabyle" "kab"
    get-name-for-language "Kapampangan" "pam"
    get-name-for-language "Kabuverdianu" "kea"
    get-name-for-language "Karakalpak" "kaa"
    get-name-for-language "Kashubian" "csb"
    get-name-for-language-2codes "Kazakh" "kk-latn" "kk"
    get-name-for-language "Kichwa_Chimboraazo" "qug"
    get-name-for-language "Kikuyu" "ki"
    get-name-for-language "Kinyarwanda" "rw"
    get-name-for-language "Kongo" "kg"
    get-name-for-language "Konkani_Goa" "gom-latn"
    get-name-for-language "Kotava" "avk"
    get-name-for-language "Kurdish" "ku"
    get-name-for-language "Kyrgyz" "ky"
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
    get-name-for-language "Luganda" "lg"
    get-name-for-language "Luxembourgish" "lb"
    get-name-for-language "Macedonian_Slavic" "mk"
    get-name-for-language "Madurese" "mad"
    get-name-for-language "Malagasy" "mg"
    get-name-for-language "Malay" "ms"
    get-name-for-language "Maltese" "mt"
    get-name-for-language "Manx" "gv"
    get-name-for-language "Maori" "mi"
    get-name-for-language "Minangkabau" "min"
    get-name-for-language "Mirandese" "mwl"
    get-name-for-language "Mongol" "mn"
    get-name-for-language "Nahuatl" "nah"
    get-name-for-language "Nauru" "na"
    get-name-for-language "Navajo" "nv"
    get-name-for-language "Neapolitan" "nap"
    get-name-for-language "Norman" "nrm"
    get-name-for-language-2variants "Norwegian_Nynorsk" "nn" "Norwegian" "nb"
    get-name-for-language "Novial" "nov"
    get-name-for-language "Occitan" "oc"
    get-name-for-language "Oromo" "om"
    get-name-for-language "Ossetic" "os"
    get-name-for-language "Pangasinan" "pag"
    get-name-for-language "Papiamento" "pap"
    get-name-for-language "Picard" "pcd"
    get-name-for-language "Piemontese" "pms"
    get-name-for-language "Pitkern" "pih"
    get-name-for-language "Plautdietsch" "pdt"
    get-name-for-language "Polish" "pl"
    get-name-for-language-2variants "Portuguese_Brazilian" "pt-br" "Portuguese" "pt"
    get-name-for-language "Quechua" "qu"
    get-name-for-language "Romani_Vlax" "rmy"
    get-name-for-language "Romanian" "ro"
    get-name-for-language "Romansh" "rm"
    get-name-for-language "Rundi" "rn"
    get-name-for-language "Russian" "ru"
    get-name-for-language "Sakizaya" "szy"
    get-name-for-language "Sami_Inari" "smn"
    get-name-for-language "Sami_North" "se"
    get-name-for-language "Sami_Skolt" "sms"
    get-name-for-language "Sami_South" "sma"
    get-name-for-language "Samoan" "sm"
    get-name-for-language "Samogitian" "sgs"
    get-name-for-language "Sango" "sg"
    get-name-for-language "Sardinian" "sc"
    get-name-for-language "Scots" "sco"
    get-name-for-language "Scottish_Gaelic" "gd"
    get-name-for-language "Seediq" "trv"
    get-name-for-language-2variants "Bosnian" "bs" "SerboCroatian" "sh"
    get-name-for-language-2variants "Croatian" "hr" "SerboCroatian" "sh"
    get-name-for-language-2variants "Serbian" "sr" "SerboCroatian" "sh"
    get-name-for-language-2variants "Serbian" "sr-el" "SerboCroatian" "sh"
    get-name-for-language "Shona" "sn"
    get-name-for-language "Sicilian" "scn"
    get-name-for-language "Silesian" "szl"
    get-name-for-language "Slavonic_Church" "cu"
    get-name-for-language "Slovak" "sk"
    get-name-for-language "Slovene" "sl"
    get-name-for-language "Somali" "so"
    get-name-for-language "Sorbian_Lower" "dsb"
    get-name-for-language "Sorbian_Upper" "hsb"
    get-name-for-language "Spanish" "es"
    get-name-for-language "Sundanese" "su"
    get-name-for-language "Surinamese" "srn"
    get-name-for-language "Swahili" "sw"
    get-name-for-language "Swazi" "ss"
    get-name-for-language "Swedish" "sv"
    get-name-for-language "Tagalog" "tl"
    get-name-for-language "Tahitian" "ty"
    get-name-for-language "Tajiki" "tg-latn"
    get-name-for-language "Tarantino" "roa-tara"
    get-name-for-language "Tatar_Crimean" "crh-latn"
    get-name-for-language "Tatar" "tt-latn"
    get-name-for-language "Tetum" "tet"
    get-name-for-language "Tok_Pisin" "tpi"
    get-name-for-language "Tongan" "to"
    get-name-for-language "Tsonga" "ts"
    get-name-for-language "Turkish" "tr"
    get-name-for-language "Turkmen" "tk"
    get-name-for-language "Udmurt" "udm"
    get-name-for-language "Ukrainian" "uk"
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
    get-name-for-language "Xhosa" "xh"
    get-name-for-language "Yoruba" "yo"
    get-name-for-language "Zazaki_Dimli" "diq"
    get-name-for-language "Zeelandic" "zea"
    get-name-for-language "Zhuang" "za"
    get-name-for-language "Zulu" "zu"
}

function get-location-entry() {
    NAMES="$(get-names)"

    [ -z "${NAMES}" ] && return

    LOCATION_ID=$(echo "${ENGLISH_NAME}" | \
        iconv -f utf8 -t ascii//TRANSLIT | \
        sed 's/-le-/_le_/g' | \
        sed 's/ /_/g' | sed "s/\'//g" | \
        sed 's/\(north\|west\|south\|east\)ern/\1/g' | \
        sed 's/^\(north\|west\|south\|east\)_\(.*\)$/\2_\1/g' | \
        tr '[:upper:]' '[:lower:]')

    echo "  <LocationEntity>"
    echo "    <Id>${LOCATION_ID}</Id>"
    echo "    <WikidataId>${WIKIDATA_ID}</WikidataId>"
    echo "    <GameIds>"
    echo "    </GameIds>"
    echo "    <Names>"
    get-names | sort | uniq
    echo "    </Names>"
    echo "  </LocationEntity>"
}

echo ""
get-location-entry
