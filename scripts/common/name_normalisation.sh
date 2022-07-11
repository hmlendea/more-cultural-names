#!/bin/bash

TRANSLITERATION_API_URI="http://hmlendea-translit.duckdns.org:9584/Transliteration"

function get-transliteration() {
    RAW_TEXT="${1}"
    LANGUAGE="${2}"
    ENCODED_TEXT=$(echo "${RAW_TEXT}" | python -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read()))")
    TRANSLITERATION_API_ENDPOINT="${TRANSLITERATION_API_URI}?text=${ENCODED_TEXT}&language=${LANGUAGE}"

    curl --silent --insecure --location "${TRANSLITERATION_API_ENDPOINT}" --request GET
}

function transliterate-name() {
    LANGUAGE_CODE="${1}" && shift
    RAW_NAME=$(echo "$*" | \
                sed 's/^"\(.*\)"$/\1/g' | \
                sed 's/^null//g' | \
                sed 's/%0A$//g')
    LATIN_NAME="${RAW_NAME}"

    [ -z "${RAW_NAME}" ] && return

    [ "${LANGUAGE_CODE}" == "ary" ] && LANGUAGE_CODE="ar"
    [ "${LANGUAGE_CODE}" == "arz" ] && LANGUAGE_CODE="ar"
    [ "${LANGUAGE_CODE}" == "be-tarask" ] && LANGUAGE_CODE="be"
    [ "${LANGUAGE_CODE}" == "pnt" ] && LANGUAGE_CODE="grc"

    if [ "${LANGUAGE_CODE}" == "ab" ] \
    || [ "${LANGUAGE_CODE}" == "ady" ] \
    || [ "${LANGUAGE_CODE}" == "ar" ] \
    || [ "${LANGUAGE_CODE}" == "ba" ] \
    || [ "${LANGUAGE_CODE}" == "be" ] \
    || [ "${LANGUAGE_CODE}" == "bg" ] \
    || [ "${LANGUAGE_CODE}" == "bn" ] \
    || [ "${LANGUAGE_CODE}" == "cv" ] \
    || [ "${LANGUAGE_CODE}" == "cu" ] \
    || [ "${LANGUAGE_CODE}" == "el" ] \
    || [ "${LANGUAGE_CODE}" == "grc" ] \
    || [ "${LANGUAGE_CODE}" == "gu" ] \
    || [ "${LANGUAGE_CODE}" == "he" ] \
    || [ "${LANGUAGE_CODE}" == "hi" ] \
    || [ "${LANGUAGE_CODE}" == "hy" ] \
    || [ "${LANGUAGE_CODE}" == "hyw" ] \
    || [ "${LANGUAGE_CODE}" == "iu" ] \
    || [ "${LANGUAGE_CODE}" == "ja" ] \
    || [ "${LANGUAGE_CODE}" == "ka" ] \
    || [ "${LANGUAGE_CODE}" == "kk" ] \
    || [ "${LANGUAGE_CODE}" == "kn" ] \
    || [ "${LANGUAGE_CODE}" == "ko" ] \
    || [ "${LANGUAGE_CODE}" == "ky" ] \
    || [ "${LANGUAGE_CODE}" == "mk" ] \
    || [ "${LANGUAGE_CODE}" == "ml" ] \
    || [ "${LANGUAGE_CODE}" == "mn" ] \
    || [ "${LANGUAGE_CODE}" == "mr" ] \
    || [ "${LANGUAGE_CODE}" == "os" ] \
    || [ "${LANGUAGE_CODE}" == "ru" ] \
    || [ "${LANGUAGE_CODE}" == "sa" ] \
    || [ "${LANGUAGE_CODE}" == "si" ] \
    || [ "${LANGUAGE_CODE}" == "sr" ] \
    || [ "${LANGUAGE_CODE}" == "ta" ] \
    || [ "${LANGUAGE_CODE}" == "te" ] \
    || [ "${LANGUAGE_CODE}" == "th" ] \
    || [ "${LANGUAGE_CODE}" == "udm" ] \
    || [ "${LANGUAGE_CODE}" == "uk" ] \
    || [ "${LANGUAGE_CODE}" == "zh" ] \
    || [ "${LANGUAGE_CODE}" == "zh-hans" ]; then
        LATIN_NAME=$(get-transliteration "${RAW_NAME}" "${LANGUAGE_CODE}")
    fi

    echo "${LATIN_NAME}"
}

function normalise-name() {
    local LANGUAGE_CODE="${1}" && shift
    local NAME=$(echo "$*" | \
                    sed 's/^\"\(.*\)\"$/\1/g' | \
                    awk -F" - " '{print $1}' | \
                    awk -F"/" '{print $1}' | \
                    awk -F"(" '{print $1}' | \
                    awk -F"," '{print $1}' | \
                    sed \
                        -e 's/\s*<alternateName .*$//g' \
                        -e 's/[…]//g' \
                        -e 's/^\s*//g' \
                        -e 's/\s*$//g')

    local P_ABBEY="[AaOo][bp][abd]\([ae][z]*[iy][ae]*\|ij\|tstv[oí]\)\|Benediktinerabtei"
    local P_AGENCY="[Aa]gen[cț][ijy][a]*"
    local P_ANCIENT="[Aa]ncient\|Antiikin [Aa]nti[i]*[ck]\(a\|in\)*\|Ar[c]*ha[ií][ac]"
    local P_AUTONOMOUS_GOVERNMENT="[Aa][uv]tonom\(e|\noye\|ous\) \([Gg]overnment\|[Pp]ravitel’stvo\|[Rr]egering\)\|[Gg]obierno [Aa]ut[oó]nomo\|[Öö]zerk [Hh]ükümeti"
    local P_CANTON="[CcKk][’]*[hy]*[aāe][i]*[nṇ][tṭ][’]*[aoóuū]n\(a\|i\|o\|s\|u[l]*\)*"
    local P_CASTLE="[CcGgKk]a[i]*[sz][lt][ei]*[aál][il]*[eoulmn]*[a]*\|[Cc]h[aâ]teau\|Dvorac\|[KkQq]al[ae]s[iı]\|Z[aá]m[aeo][gk][y]*"
    local P_CATHEDRAL="[CcKk]at[h]*[eé]dr[ai][kl][aeoó]*[s]*"
    local P_CHURCH="[Bb]iserica\|[Cc]hiesa\|[Cc]hurch\|[Éé]glise\|[Ii]greja\|[Kk]yōkai"
    local P_CITY="[Cc]iud[aá][dt]*\|[Cc]ivitas\|[CcSs]\(ee\|i\)[tṭ]\+[aàeiy]\|Nagara\|Oraș\(ul\)*\|Śahara\|Sich’i\|[Ss]tadt"
    local P_COMMUNE="[CcKk]om[m]*un[ae]*\|[Kk]özség"
    local P_COUNCIL="[Cc]o[u]*n[cs][ei]l[l]*\(iul\)\|[Cc]omhairle"
    local P_COUNTRY="[Nn]egeri"
    local P_COUNTY="[Cc]o[u]*[mn]t\(a\(do\|t\)\|y\)\|Landgra[a]*fs\(cha\(ft\|p\)\|tvo\)"
    local P_DEPARTMENT="[DdḌḍ][eéi]p[’]*[aā][i]*r[tṭ][’]*[aei]*m[aeēi][e]*[nṇ]*[gtṭ]*[’]*\(as\|i\|o\|u\(l\|va\)*\)*\|Ilākhe\|Penbiran\|Tuṟai\|Vibhaaga\|Zhang Wàt"
    local P_DESERT="Anapat\|[Aa]nialwch\|Çölü\|[Dd][i]*[eè]*[sșz][iy]*er[tz]\(h\|o\|ul\)*\|Eḍāri\|Gaineamhh\|Gurun\|Hoang\|Maru[bs]h\(tal\|ūmi\)\|[Mm]ortua\|Pālaivaṉam\|Pustynia\|Raṇa\|Sa[bm]ak[u]*\|Se wedhi\|shāmò\|Tá Laēy Saāi\|Vaalvnt"
    local P_DIOCESE="[Dd]io[eít]*[cks][eēi][sz][eēi]*[s]*"
    local P_DISTRICT="[Aa]pygarda\|[Bb]arrutia\|[Bb]ucağı\|Ḍāḥīẗ\|[Dd][h]*[iy]str[eiy][ckt]*[akt][eouy]*[als]*\|[Iiİi̇]l[cç]esi\|járás\|Jil[lh]*[aāeo][a]*\|Koān\|Māvaṭṭam\|[Pp]asuni\|[Pp]irrâdâh\|Qu\(ận\)*\|[Rr]a[iy]on[iu]\|sum"
    local P_DUCHY="bǎijué\|[Dd][uü][ck]\([aá][dt]*[otu][l]*\|h[éy]\|lüğü\)\|Hertogdom\|Kadipaten"
    local P_EMIRATE="Aēy Mí Raēy Dtà\|[ĀāEeÉéƏəIiYy]m[aāi]r[l]*[aàāẗhi][dğty]*\([aeiou][l]*\)*\|qiúcháng\|Saamiro\|Tiểu vương quốc\|T’ohuguk"
    local P_FORT="\([CcKk][aá]str[aou][lm]*\|Festung\|[Ff]ort\(e\(tsya\)*\|ul\)*\|[Ff]ort\(ale[sz]a\|[e]*ress[e]*\)\|[Ff]ort[r]*e[t]*s[s]*[y]*[ae]*\|[Kk]repost\|[Tv]rdina\|[Yy]ōsai\|[Zz]amogy\)\( \(roman\|royale\)\)*"
    local P_GMINA="[Gg][e]*m[e]*[ij]n[d]*[ae]"
    local P_HUNDRED="[Hh][äe]r[r]*[ae]d\|[Hh]undred\|[Kk]ihlakunta"
    local P_ISLAND="[Aa]raly\|Đảo\|[Ǧǧ]zīrẗ\|[Ii]l[hl]a\|[Ii]nsula\|[Ii]sl[ae]\|[Ii]sland\|[Îî]le\|[Nn][eḗ]sos\|Ostr[io]v\|Sŏm"
    local P_KINGDOM="guó\|[Kk][eoö]ni[n]*[gk]r[e]*[iy][cej]*[hk]\|K[io]ng[e]*d[oø]m\(met\)*\|[Kk]irályság\|[Kk][o]*r[oa]l\(ev\)*stvo\|Ōkoku\|[Rr]egatul\|[Rr][eo][giy][an][eolu][m]*[e]*\|[Rr]īce\|[Tt]eyrnas"
    local P_LAKE="Gölü\|[Ll]a\(c\|cul\|go\|ke\)\|[Nn][uú][u]*r\|[Oo]zero"
    local P_LANGUAGE="[Bb][h]*[aā][a]*[sṣ][h]*[aā][a]*\|[Ll][l]*[aeií][mn][g]*[buv]*[ao]\(ge\)*"
    local P_MOUNTAIN="\([Gg]e\)*[Bb]i[e]*rge[r]*\|[Dd]ağları\|[GgHh][ao]ra\|Ǧibāl\|[Mm][ouū][u]*n[tț[[aei]*\([gi]*[ln][es]\|ii\|s\)*\|[Pp]arvata[ṁ]*\|[Ss]hānmài"
    local P_MONASTERY="[Kk]l[aáo][o]*[sš]t[eo]r\(is\)*\|\(\(R[eo][y]*al\|[BV]asilikó\) \)*[Mm][ăo]n[aăe]st[eèḗiíy]r\(e[a]*\|i\|io[a]*\|o\|y\)*\|[Mm]onaĥejo\|[Mm]osteiro\|[Ss]hu[u]*dōin"
    local P_MUNICIPIUM="[Bb]elediyesi\|Chibang Chach’ije\|Chū-tī\|Đô thị tự trị\|[Kk]ong-[Ss]iā\|[Kk]otamadya\|[Mm]eūang\|[Mm][y]*un[i]*[t]*[cs]ip[’]*\([aā]*l[i]*[dtṭ][’]*\(a[ds]\|é\|et’i\|[iī]\|y\)\|i[ou][lm]*\)\|[Nn]agara [Ss]abhāva\|[Nn]a[gk][a]*r[aā]\(pālika\|ṭci\)\|[Pp]ašvaldība\|[Pp][a]*urasabh[āe]\|[Ss]avivaldybė"
    local P_MUNICIPALITY="Bwrdeistref\|D[ḗií]mos\|O[bp]\([cćčš]\|s[hj]\)[t]*ina"
    local P_NATIONAL_PARK="[Nn]ational [Pp]ark\|Par[cq]u[el] Na[ctț]ional\|[Vv]ườn [Qq]uốc"
    local P_OASIS="[aā]l-[Ww]āḥāt\|[OoÓóŌō][syẏ]*[aáāeē][sz][h]*[aiīeėē][ans]*[uŭ]*\|Oūh Aēy Sít"
    local P_PENINSULA="[Bb][aá]n[ ]*[dđ][aả]o\|[Dd]uoninsulo\|[Hh]antō\|[Ll]edenez\|[Nn]iemimaa\|[Pp][ao][luŭ][ouv]ostr[ao][uŭv]\|[Pp][eé]n[iíì][n]*[t]*[csz][ou][lł][aāe]\|[Pp]enrhyn\|Poàn-tó\|[Ss]emenanjung\|Tīpakaṟpam\|[Yy]arim [Oo]roli\|[Yy]arımadası\|[Žž]arym [Aa]raly"
    local P_PLATEAU="Alt[io]p[il]*[aà]\(no\)*\|Àrd-thìr\|Daichi\|gāoyuán\|Hḍbẗ\|ordokia\|[Pp][’]*lat[’]*[e]*\([aå][nu]\(et\)*\|o\(s[iu]\)*\)\|[Pp]lošina\|[Pp]lynaukštė"
    local P_PREFECTURE="[Pp]r[aäeé][e]*fe[ckt]t[uúū]r[ae]*"
    local P_PROVINCE="[Ee]par[ck]hía\|Mḥāfẓẗ\|Mqāṭʿẗ\|[Pp][’]*r[aāou][bpvw][ëií][nñ][t]*[csz]*[eėiíjoy]*[aeėnsz]*\|Pradēśa\|Pr[aā][a]*nt[a]*\|Rát\|[Ss][h]*[éě]ng\|Shuu\|suyu\|Wilayah"
    local P_REGION="[Aa]ñcala\|[Bb]ölgesi\|[Ee]skualdea\|Gobolka\|[Kk]alāpaya\|Khu vực\|[Kk]shetr\|Kwáāen\|[Pp]akuti\|[Pp]aḷāta\|[Pp]eri\(f\|ph\)[eéē]r[e]*i[j]*a\|[Pp]iirkond\|[Pp]r[a]*desh[a]*\|[Pp]rāntaṁ\|[Rr][eé][gģhx][ij]*\([ãoóu][ou]*n*[ei]*[as]*\|st[aā]n\)\|[Rr]ijn"
    local P_REPUBLIC="Cộng hòa\|[DdTt][aáä][aä]*[ʹ]*s[s]*[ei]*v[aäá][ʹ]*ld[di]\|[Dd][eēi]mokr[h]*atía\|gōnghé\|[Gg]weriniaeth\|[Jj]anarajaya\|Khiung-fò-koet\|Kongwaguk\|Köztársaság\|Kyōwa\( Koku\)*\|Olómìnira\|Praj[aā][a]*[s]*t[t]*a[a]*\(k\|ntra\)\|[Rr][eéi][s]*[ ]*p[’]*[aāuüùúy][ā’]*b[ba]*l[eií][’]*[cgkq][ck]*[’]*\([ai]\|as[ıy]\|en\|[hḥ]y\|i\|ue\)*\|[Ss]ăā-taā-rá-ná-rát\|[Tt]a[sz][ao]val[dt]\(a\|kund\)"
    local P_RIVER="Abhainn\|Afon\|[Ff][il]u\(me\|viul\)\|Gawa\|Nadī\|Nhr\|[Rr]âu[l]*\|[Rr]iver\|Sungai"
    local P_RUIN="[Rr]uin[ae]*"
    local P_STATE="Bang\|[EeÉéIi]*[SsŜŝŜŝŠšŞş]*[h]*[tṭ][’]*[aeē][dtṭu][’]*[aeiıosu]*[l]*\|[Oo]sariik\|[Oo]st[’]*an[ıi]\|Ūlāīẗ\|[Uu]stoni\|valstija*"
    local P_TEMPLE="[Dd]ēvālaya\(mu\)*\|[Kk]ōvil\|[Mm][a]*ndir[a]*\|Ná Tiān\|[Pp]agoda\|[Tt]emp[e]*l[eou]*[l]*"
    local P_TOWNSHIP="[CcKk]anton[ae]*\(mendua\)*\|[Tt]ownship"
    local P_UNIVERSITY="[Dd]aigaku\|\(Lā \)*[BbVv]i[sś][h]*[vw]\+\(a[bv]\)*idyāla[yẏ][a]*[ṁ]*\|[Oo]llscoil\|[Uu]niversit\(ate[a]a*\|y\)\|[Vv]idyaapith"
    local P_VOIVODESHIP="V[éo][i]*[e]*vod[ae]*\(s\(hip\|tv[ií]\)\|t\(e\|ul\)\)"

    local P_OF="\([AaĀā]p[h]*[a]*\|[Dd]\|[Dd][aeio][ls]*\|gia\|[Oo]f\|[Mm]ạc\|ng\|[Tt]a\|t[ēi]s\|[Tt]o[uy]\|van\|w\|[Yy]r\)[ \'\"’']"

    local COMMON_PATTERNS="${P_ABBEY}\|${P_AGENCY}\|${P_ANCIENT}\|${P_AUTONOMOUS_GOVERNMENT}\|${P_CANTON}\|${P_CASTLE}\|${P_CATHEDRAL}"
    COMMON_PATTERNS="${COMMON_PATTERNS}\|${P_CHURCH}\|${P_CITY}\|${P_COMMUNE}\|${P_COUNCIL}\|${P_COUNTRY}\|${P_COUNTY}\|${P_DESERT}"
    COMMON_PATTERNS="${COMMON_PATTERNS}\|${P_DEPARTMENT}\|${P_DIOCESE}\|${P_DISTRICT}\|${P_DUCHY}\|${P_EMIRATE}\|${P_FORT}\|${P_GMINA}"
    COMMON_PATTERNS="${COMMON_PATTERNS}\|${P_HUNDRED}\|${P_ISLAND}\|${P_KINGDOM}\|${P_LAKE}\|${P_LANGUAGE}\|${P_MONASTERY}\|${P_MOUNTAIN}"
    COMMON_PATTERNS="${COMMON_PATTERNS}\|${P_MUNICIPIUM}\|${P_MUNICIPALITY}\|${P_NATIONAL_PARK}\|${P_OASIS}\|${P_PENINSULA}\|${P_PLATEAU}"
    COMMON_PATTERNS="${COMMON_PATTERNS}\|${P_PREFECTURE}\|${P_PROVINCE}\|${P_REGION}\|${P_REPUBLIC}\|${P_RIVER}\|${P_RUIN}\|${P_STATE}"
    COMMON_PATTERNS="${COMMON_PATTERNS}\|${P_TEMPLE}\|${P_TOWNSHIP}\|${P_UNIVERSITY}\|${P_VOIVODESHIP}"

    local TRANSLITERATED_NAME=$(transliterate-name "${LANGUAGE_CODE}" "${NAME}")
    local NORMALISED_NAME=$(echo "${TRANSLITERATED_NAME}" | \
        perl -p0e 's/\r*\n/ /g' | \
        awk -F" - " '{print $1}' | \
        awk -F"/" '{print $1}' | \
        awk -F"(" '{print $1}' | \
        awk -F"," '{print $1}' | \
        sed \
            -e 's/^"\(.*\)"$/\1/g' \
            -e 's/^\s*//g' \
            -e 's/\s*$//g' \
            -e 's/^ẖ/H̱/g' \
            \
            -e 's/ AG$//g' \
            \
            -e 's/P‍/P/g' \
            -e 's/T‍/T/g' \
            -e 's/p‍/p/g' \
            -e 's/t‍/t/g')

    NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | \
        sed \
            -e 's/^\('"${COMMON_PATTERNS}"'\)\s\+\('"${P_OF}"'\)*//g' \
            -e 's/[ ’-]\('"${COMMON_PATTERNS}"'\)$//g' \
            \
            -e 's/\([^\s]\)-\s*/\1-/g' \
            -e 's/[·]//g' \
            -e 's/\(.\)\1\1/\1\1/g' \
            -e 's/^\s*//g' \
            -e 's/\s*$//g' \
            -e 's/\s\s*/ /g')

        if [ "${LANGUAGE_CODE}" == "ko" ]; then
            NORMALISED_NAME=$(sed 's/[’\"]//g' <<< "${NORMALISED_NAME}")
        fi

        if [ "${LANGUAGE_CODE}" != "ar" ] && \
           [ "${LANGUAGE_CODE}" != "ga" ] && \
           [ "${LANGUAGE_CODE}" != "jam" ] && \
           [ "${LANGUAGE_CODE}" != "jbo" ]; then
            NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^\([a-z]\)/\U\1/g')
        fi

        [ "${LANGUAGE_CODE}" == "kaa" ] && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed "s/U'/Ú/g")
        [ "${LANGUAGE_CODE}" == "lt" ]  && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^Šv\./Šventasis/g')
        [ "${LANGUAGE_CODE}" == "zh" ]  && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/-//g')
        [ "${LANGUAGE_CODE}" == "ang" ] && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/enrice$/e/g')

        NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^L'"'"'/l'"'"'/g')

        echo "${NORMALISED_NAME}"
}

function nameToLocationId() {
    local NAME="${1}"
    local LOCATION_ID=""

    LOCATION_ID=$(echo "${NAME}" | sed \
            -e 's/æ/ae/g' \
            -e 's/\([ČčŠšŽž]\)/\1h/g' \
            -e 's/[Ǧǧ]/j/g' | \
        iconv -f utf8 -t ascii//TRANSLIT | \
        tr '[:upper:]' '[:lower:]')

    LOCATION_ID=$(echo "${LOCATION_ID}" | sed \
            -e 's/ /_/g' \
            -e 's/'"\'"'/-/g' \
            -e 's/^-*//g' \
            -e 's/-*$//g' \
            -e 's/-\+/-/g' \
            \
            -e 's/central/centre/g' \
            -e 's/\(north\|west\|south\|east\)ern/\1/g' \
            \
            -e 's/borealis/north/g' \
            -e 's/occidentalis/west/g' \
            -e 's/australis/south/g' \
            -e 's/orientalis/east/g')

    for I in 1 .. 2; do
        LOCATION_ID=$(echo "${LOCATION_ID}" | sed \
            -e 's/^\(north\|west\|south\|east\)_\(.*\)$/\2_\1/g' \
            -e 's/^\(lower\|upper\|inferior\|superior\)_\(.*\)$/\2_\1/g' \
            -e 's/^\(minor\|maior\|lesser\|greater\)_\(.*\)$/\2_\1/g' \
            -e 's/^\(centre\)_\(.*\)$/\2_\1/g')
    done

    echo "${LOCATION_ID}"
}

function locationIdToSearcheableId() {
    local LOCATION_ID="${1}"

    echo "${LOCATION_ID}" | sed \
        -e 's/^[ekdcb]_//g' \
        -e 's/[_-]//g' \
        -e 's/\(baron\|castle\|church\|city\|fort\|temple\|town\)//g'
}
