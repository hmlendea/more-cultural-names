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
    local NAME=$(echo "$*" | sed 's/^"\(.*\)"$/\1/g')
    local TRANSLITERATED_NAME=$(transliterate-name "${LANGUAGE_CODE}" "${NAME}")
    local NORMALISED_NAME=$(echo "${TRANSLITERATED_NAME}" | \
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
            -e 's/[gk]iel[l]*[aâ]$//g' \
            -e 's/\(n\|ṉ\) \([Pp]\|P‍\|p‍\)e\(n\|[ṉ]*\)i\(n\|[ṉ]*\)[cs]ulā$//g' \
            -e 's/^języki \(.*\)skie$/\1ski/g' \
            -e 's/^Półwysep \(.*\)ski$/\1/g' \
            -e 's/an Tazovaldkund$//g' \
            -e 's/an[sš]*[cćč]ina$/a/g' \
            -e 's/anis\(ch\|k\)$/a/g' \
            -e 's/ańĭskŭ językŭ$/a/g' \
            -e 's/ans[’]*ka\(ja\)* mova$/a/g' \
            -e 's/as \(vilāj[as]\|mintaka\)$/a/g' \
            -e 's/hantou$//g' \
            -e 's/iin tsöl$//g' \
            -e 's/īn Ardhadvīpaya$//g' \
            -e 's/in autiomaa$//g' \
            -e 's/janski jazik$/ja/g' \
            -e 's/jas \(grāfiste\|province\)$/ja/g' \
            -e 's/jos \(provincija\|pusiasalis\)$/ja/g' \
            -e 's/ko \(konderria\|probintzia\)$//g' \
            -e 's/n dili$//g' \
            -e 's/n kieli$//g' \
            -e 's/n kreivikunta$//g' \
            -e 's/nag ævzag$//g' \
            -e 's/nski ezik$//g' \
            -e 's/o \(apskritis\|emyratas\|grafystė\)$/as/g' \
            -e 's/ørkenen$/a/g' \
            -e 's/os \(vilaja\)$/as/g' \
            -e 's/s[’]*k[iy]y p\(i\|ol\)[uv]ostr[io]v$//g' \
            -e 's/skagi$//g' \
            -e 's/skaya oblast[’]*$/sk/g' \
            -e 's/ske \(gŏdki\|rěče\)$/ska/g' \
            -e 's/x žudecs$/a/g' \
            -e 's/ý polostrov$/o/g' \
            -e 's/yanskiy[e]* \(yazyk[i]*\)$/ya/g' \
            -e 's/yn khoig$//g' \
            \
            -e 's/^\(Byen\|Dinas\|Ìlú\|Mbanza ya\|Sita\|Syudad han\) //g' \
            -e 's/^Co[ou]*nt\(ae\|ea\|y\) \(d[ei] \|of \)*//g' \
            -e 's/^Con[dt][aá]d*[eou] \(d[eo] \)*//g' \
            -e 's/^Comt[aé]t* de //g' \
            -e 's/^[CcKk]om*un*[ea]*[n]* //g' \
            -e 's/^[Ll][ei]ngua //g' \
            -e 's/^D Regioon //g' \
            -e 's/^\([Ee]*[SsŠš]ta[dt][eou]*[l]*\|Jangwa\|Kongedømmet\|[Pp]ar[r]*o[i]*\(cc\|q\|ss\)\(e\|[hu]ia\)\|\([Pp]\|P‍\|p‍\)en[ií]n[cs]ul[aā]\|[Pp][’]*r[ao][bpvw][ëií][nñ][t]*[csz]*[eiíjoy]*[aez]*\|Sultanat\) \([dl]*[aeiou]*[ '"'"']\|of\)*//g' \
            -e 's/^\(Āltepētl\|Bahasa\|Bán đảo\|Bogserbåten\|Burg\|Cathair\|Comitatu[ls]\|Daerah\|Dorerit\|Emirlando\|Eparchía\|G[e]*m[ei][e]*n[t]*[ae]*\|Glṓssa\|Glùm Paā-săā\|Gr[ao][a]*f\(ija\|lando\|skap\)\|Grad\|Gurun\|Hạt\|Horad\|[Hh]ra[bf]stv[aí]\|Huyện\|[Ii]dioma\|Ìpínlẹ̀\|Iqlīm\|[Jj]ęzyk\|K'"'"'alak'"'"'i\|Kástro\|[Kk][eo]ninkr[iy][j]*k\|Kêr\|Kerajaan\|Komēteía\|Kontelezh\|Kreis\|Kwáāen\|Kr[aó]l[j]*e\(stwo\|vina\)\|[Ll][eií][mn][g]*[bu]*a\|M[e]*ch[e]*wz\|Memlekt\|Mqāṭʿẗ\|Municipiu[lmo]\|Okręg\|O[bp]\(s[hj]\|š\)tina\|Oraș\|Paā-săā\|Pasiolak\|Potamós\|Prikhod\|Pustynia\|Qarku\|Râāt-chá-aā-naā-zhàk\|Raka\|Rát\|Rīf\|Río\|Sa mạc\|Schloss\|Sir\|Stadt\(kreis\)*\|Swydd\|ti\|[Tt]iếng\|[Tt]yrt\|Ūlāīẗ\|[Vv]ioska\|[VvWw]il[l]*a\(yah\)*\|Vilojati\|Vostraŭ\|Wikang\|Zamok\|Zıwanê\) //g' \
            -e 's/^\(Chetsey H'"'"'y\|Kâāp-sà-mùt\|Khu vực\|Jimbo ya\|Lalawigan ng\|Marz\|Mkoa wa\|Penrhyn y\|Talaith\|Tawilayt n\|Tighrmt n\Vostraŭ\||W[iı]lay\(a\|ah\|etê\)\) \(\(de\|ya\) \)*//g' \
            -e 's/^\(Autonome Gemeinschaft\|Bprà[ -][Tt]âēyt\|Com[m]*unitate[a]* Autonom[aăe]\|Ilang ng\|Kreisfreie Stadt\|Nhóm ngôn ngữ\|Săā-taā-rá-ná-rát\|[Tt]âēyt[ -][Mm]on[ -][Tt]on\|Tá[ -][Ll]aēy[ -][Ss]aāi\|Thị trấn\)[ -]//g' \
            -e 's/^\([Cc]ast\([ei]l\|r\)[lu]*[mo]*\|\([CcÇçSs]\|Tz\)[eiy][uv]*[dt]*[aáàæ][dt]*[e]*[a]*\|[CcSs]\(ee\|i\)[t]*[aàey]\|[Cc]h[aâ]teau\|[CcKk]o[mn][dt]\(a[dt][o]*\|[eé]\)\|[CcKk][aāo]*[uv]*[nṇ][tṭ][iīy][e]*\|Dēmokratía\|[Dd][eé]part[aei]m[ei]*nt[ou]*[l]*\|[Dd][eéi][sz][iy]*er[tz][ho]*\|[Dd]istr[ei][ck]*t[t]*o*\|Fort\(aleza\|ress\)\|I[ls]l[ae]\|[JjŽž]ud[iz]*e[ctțţ]\(ul\)*\|Kingdom\|M[a]*ml[u]*k[a]*ẗ\|Parish\|[Pp]r[eé]fectur[ae]\|Pr[ei]n[cgs][ei]p[aáà][dt]*[eou]*\|[Rr]e[gģhx][ij]*[oóu]n*i*[aes]*\|[Rr][eo][giy][an][eou][m]*[e]*\|R[ei][s ]*p[auüù]b[b]*l[ií][ck][ck]*\([ai]\|en\)*\|[Ss]hahrest[aā]n\|State\|Thành\|[Tt][h]*[eé]ma\|[Tt]zountéts\|[VvWw]il[l]*[ae]\(ya\)*\|Xian\) \('"'"'e \|d'"'"'\|[dty][aeiîu][l]* \|[eë]d \|han \|[t]*[Oo][fu]* \|phố \)*//g' \
            \
            -e 's/[ ’-]\(AG\|[Aa]imag\|[Aa]irurando\|aju\|alue\|[Aa]ñcala\|apskritis\|[Bb]ar[ou]n[iy][am]*[u]*\|[Bb]hasa\|Bikéyah\|[Bb]ölgesi\|[Cc]alabro\|[Cc]astle\|çayı\|Chê\|Chhī\|Chibang\|Cit[t]*[aày]\|[CcKk][aāo]*[uv]*[nṇ][tṭ]\([iīy]\|lu[gğ]u]\)\|[cs]h[h]*[ìī]\|Çölü\|[Cc]omitatus\|Cumhuriyeti\|dar[ij]a\|[Dd]ǎo\|[Dd]esert\|Dhāma\|Eḍāri\|[Ee]na\|[Ee]rusutaa\|[Ee]*[Ss][h]*t[’]*a[dt][’]*[eio]\|Eyaleti\|[Ff]örsamling\|[Gg]aṇarājya\|[Gg]awa\|gielda\|[Gg]o\|[Gg]ōng[ -][Hh]é[ -][Gg]uó\|[Gg]overnorate\|[Gg]rad[ŭ]*\|grubu\|guovlu\|Hahoodzo\|hálvoyggin\|Hantou\|He\|[Ii]ngurando\|[Jj]ach'"'"'a\|[Jj]anarajaya\|jõgi\|[Jj]ou\|[Jj][iù]n\|jūnōu\|ǩalaḥy\|[Kk]alāpaya\|Kang\|Kàēyt Brì Hăān Pí Sàēyt\|[Kk]àu-khu\|ke[e]*l['"'"']*\|[Kk]hiung[ -][Ff]ò[ -][Kk]oet\|khoig\|[Kk]hu\|[Kk][iy][i]*l\|Kilisesi\|Kingdom\|[Kk]o[aā]n\|[Kk]onderria\|község\|krahvkond\|[Kk]rallığı\|[Kk]shetr\|Kūn\|Kyouku\|Kyouwa Koku\|[Ll]anguage\|[Ll]ingvo\|linn\|maak[ou]n[dt]a*\|[Mm]achi\|[Mm]ahal[iı]\|Maṇḍalam\|Marubhūmi\|[Mm]arz\|megye\|mhuriyeti\|[Mm]oḻi\|[Mm]ovy\|[Mm]unicipality\|Mura\|Nadi\|Nagar\(am\)*\|Nakaram\|Nehri\|osariik\|[Oo]ukoku\|pagasts\|[Pp]akuti\|[Pp]aḷāta\|Pālaivaṉam\|[Pp]iirkond\|[Pp]il[i]*s\|puulsaar\|qalasy\|[Rr]e[gh]i[j]*on\|rén\|[Rr]e[s]*publi[ck][a]*\(ḥy\)*\|[Rr]iver\|[SsŠš]aar[iy]*\|Sa[bm]ak[u]*\|[Ss]agrapo\|[sșş][eə]hristan[iı]\|shěng\|Shi\|Siti\|Shuu\|síksá\|[Ss][ho][aā]-[bm][òô͘]*\|sivatag\|slott\|so\(g\|cke\)n\|sritis\|Sṳ\|sultan\(at[e]*\|lığı\)\|suohkan\|suyu\|tamaneɣt\|tartomány\|tele\|tillari\|[Tt]oshi\|[Tt]ou\|Town\|tu’begi\|Udabno\|vald\|Vương quốc Hồi giáo\|[Ww]áng[ -][Gg]uó\|Wangguk\|[Xx]i[aàā]n[g]*\|yǔ\|zh[ēō]*[nu]\|[ZzŽž][h]*ude[ct]s[i]*\)$//g' \
            -e 's/[ ’-]\([Dd]epart[a]*ment\(as\)*\|[gq]r[aā]f[l]*[iı]\(ı\|ste\)\|P[aā][i]*ri\(ṣ\|sh\)\|[Mm]in[tţ]a[kq]at*\|\([Pp]\|P‍\|p‍\)en[ií]n[cs]ul[aā]\|[Pp]r[a]*d[eē][sś][h]*[a]*\|\([Pp]\|P‍\|p‍\)r[aā]*nta[ṁy][a]*\|[Pp][’]*r[ao][bpvw][ëií][nñ][t]*[csz]*[eiíjoy]*[aez]\|[Pp]rja[a]*st[t]*a[a]*k\|[Rr]e[gģh]i[j]*\([oóu]n*[ei]*[as]*\|st[aā]n\)\|[Rr]esp[uy][’]*bli[’]*[ck]a\(sy\)*\|[Ss][h]*t[’]*at[’]*[ei]\|[Vv]il[aā][jy]\(eti\|s\)\)$//g' \
            -e 's/ [Cc]o[ou]nt\(ae\|y\)$//g' \
            -e 's/ [Dd]istrict$//g' \
            -e 's/ [KkCc]om*un*[ea]*$//g' \
            -e 's/ \(Ken\|Koān\)$//g' \
            \
            -e 's/^Hl\. /Heilige /g' \
            -e 's/ mfiadini$/ Mfiadini/g' \
            \
            -e 's/^\(Abhainn\|Afon\|Ri[ou]\) //g' \
            -e 's/^\(Ducado\|Reinu\) de l'"\'"'//g' \
            -e 's/'\''i \(krahvkond\|departemang\)$//g' \
            -e 's/'\''i \(krahvkond\|departemang\)$//g' \
            \
            -e 's/[ -]\(eanangoddi\|ili\|[Ss]én[g]*\|vilayəti\)$//g' \
            \
            -e 's/ amšyn$/ Amšyn/g' \
            -e 's/ çov$/ Çov/g' \
            -e 's/ d\([eə]ng*izi\)$/ D\1/g' \
            -e 's/ d\([əei][nňņ][g]*[eizẓ]*\)$/ D\1/g' \
            -e 's/ havet$/ Havet/g' \
            -e 's/ itsasoa$/ Itsasoa/g' \
            -e 's/ j\([uū]ra\)$/ J\1/g' \
            -e 's/ m\([aeoó][rř]j*[ioe]\)$/ M\1/g' \
            -e 's/ mora$/ Mora/g' \
            -e 's/ nord$/ Nord/g' \
            -e 's/ tinĕsĕ$/ Tinĕsĕ/g' \
            -e 's/ zarez’$/ Zarez’/g' \
            -e 's/^biển /Biển /g' \
            -e 's/^m\([ae]re*\) /M\1 /g' \
            -e 's/ská poušť$/sko/g' \
            \
            -e 's/^la[cg]o* //g' \
            -e 's/^Llyn //g' \
            \
            -e 's/n-a$/na/g' \
            \
            -e 's/ norte$/ Norte/g' \
            -e 's/ septentrionale$/ Septentrionale/g' \
            \
            -e 's/[·]//g' \
            -e 's/^\s*//g' \
            -e 's/\s*$//g' \
            -e 's/\s\s*/ /g')
        
        NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | \
            perl -p0e 's/\r*\n/ /g' | \
            sed \
                -e 's/\s\s*/ /g' \
                -e 's/^\s*//g' \
                -e 's/\s*$//g')

        if [ "${LANGUAGE_CODE}" != "ga" ] && \
           [ "${LANGUAGE_CODE}" != "jbo" ]; then
            NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^\([a-z]\)/\U\1/g')
        fi

        [ "${LANGUAGE_CODE}" == "lt" ]  && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^Šv\./Šventasis/g')
        [ "${LANGUAGE_CODE}" == "zh" ]  && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/-//g')
        [ "${LANGUAGE_CODE}" == "ang" ] && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/enrice$/e/g')

        NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^L'"'"'/l'"'"'/g')

        echo "${NORMALISED_NAME}"
}

function capitalise() {
    printf '%s' "$1" | head -c 1 | tr [:lower:] [:upper:]
    printf '%s' "$1" | tail -c '+2'
}
