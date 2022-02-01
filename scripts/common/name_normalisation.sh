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

    [ "${LANGUAGE_CODE}" == "be-tarask" ] && LANGUAGE_CODE="be"

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
                    sed 's/^"\(.*\)"$/\1/g' | \
                    awk -F" - " '{print $1}' | \
                    awk -F"/" '{print $1}' | \
                    awk -F"(" '{print $1}' | \
                    awk -F"," '{print $1}' | \
                    sed 's/^\s*//g' | \
                    sed 's/\s*$//g')

    local P_ANCIENT="[Aa]ncient\|Antiikin [Aa]nti[i]*[ck]\(a\|in\)*\|Ar[c]*ha[ií][ac]"
    local P_CASTLE="[CcGgKk]a[i]*[sz][lt][ei]*[aál][il]*[eoulmn]*[a]*\|\|[Cc]h[aâ]teau\|Dvorac\|[Kk]alesi\|Zam[ao][gk][y]*"
    local P_CATHEDRAL="[CcKk]at[h]*[eé]dr[ai][kl][aeoó]*[s]*"
    local P_COUNTRY="[Nn]egeri"
    local P_DISTRICT="[Dd][iy]str[eiy][ckt]*[akt][eouy]*[as]*\|[Iiİi̇]l[cç]esi"
    local P_GMINA="[Gg][e]*m[e]*in[d]*[ae]"
    local P_ISLAND="[Ǧǧ]zīrẗ\|[Ii]nsula\|[Ii]sl[ae]\|[Ii]sland\|[Nn][eḗ]sos\|Sŏm"
    local P_PREFECTURE="[Pp]r[aäeé][e]*fe[ckt]t[uúū]r[ae]*"
    local P_PROVINCE="[Pp][’]*r[aāou][bpvw][ëií][nñ][t]*[csz]*[eėiíjoy]*[aeėsz]*"
    local P_REGION="[Rr]e[gģhx][ij]*\([oóu][ou]*n*[ei]*[as]*\|st[aā]n\)"
    local P_STATE="Bang\|[EeÉé]*[SsŜŝŜŝŠšŞş]*[h]*[tṭ][’]*[aeē][dtṭu][’]*[aeiıosu]*[l]*\|[Oo]st[’]*an[ıi]\|[Uu]stoni\|valstija*"

    local COMMON_PATTERNS="${P_ANCIENT}\|${P_CASTLE}\|${P_CATHEDRAL}\|${P_COUNTRY}\|${P_DISTRICT}\|${P_GMINA}\|${P_ISLAND}\|${P_PREFECTURE}\|${P_PROVINCE}\|${P_REGION}\|${P_STATE}"

    local TRANSLITERATED_NAME=$(transliterate-name "${LANGUAGE_CODE}" "${NAME}")
    local NORMALISED_NAME=$(echo "${TRANSLITERATED_NAME}" | \
        sed 's/^"\(.*\)"$/\1/g' | \
        awk -F" - " '{print $1}' | \
        awk -F"/" '{print $1}' | \
        awk -F"(" '{print $1}' | \
        awk -F"," '{print $1}' | \
        sed \
            -e 's/ *$//g' \
            -e 's/^\([KC]ategor[iy][e]*\)\://g' \
            -e 's/^\([Gg]e*m[ei]+n*t*[aen]\|Faritan'"'"'i\|[Mm]agaalada\) //g' \
            -e 's/^[KkCc]om*un*[ea] d[eio] //g' \
            -e 's/^\(Category\)\: //g' \
            -e 's/^Lungsod ng //g' \
            \
            -e 's/^ẖ/H̱/g' \
            \
            -e 's/P‍/P/g' \
            -e 's/T‍/T/g' \
            -e 's/p‍/p/g' \
            -e 's/t‍/t/g' \
            \
            -e 's/-i vár$//g' \
            -e 's/'\''i \(krahvkond\|departemang\)$//g' \
            -e 's/'\''i \(krahvkond\|departemang\)$//g' \
            -e 's/’agang$/’a/g' \
            -e 's/’i\(bando\|sŏm\)$/’i/g' \
            -e 's/[gk]iel[l]*[aâ]$//g' \
            -e 's/\(hyŏn\|sŏm\)$//g' \
            -e 's/\(n\|ṉ\) [Pp]e\(n\|[ṉ]*\)i\(n\|[ṉ]*\)[cs]ulā$//g' \
            -e 's/^[Dd][eḗií]mos \(.*\)oú$/\1ós/g' \
            -e 's/^D //g' \
            -e 's/^Dēmokrhatía tou//g' \
            -e 's/^Diecezja \(.*\)ska$/\1ia/g' \
            -e 's/^języki \(.*\)skie$/\1ski/g' \
            -e 's/^Kástro tou//g' \
            -e 's/^Półwysep \(.*\)ski$/\1/g' \
            -e 's/a \(fylka\|Śahara\)$//g' \
            -e 's/an Tazovaldkund$//g' \
            -e 's/an[sš]*[cćč]ina$/a/g' \
            -e 's/anis\(ch\|k\)$/a/g' \
            -e 's/ańĭskŭ językŭ$/a/g' \
            -e 's/ans[’]*ka\(ja\)* mova$/a/g' \
            -e 's/as \(vilāj[as]\|mintaka\|meģe\)$/a/g' \
            -e 's/hantou$//g' \
            -e 's/i[ -]\(félsziget\|[Gg]et\|királyság\|lään\|ringkond\)$//g' \
            -e 's/iin tsöl$//g' \
            -e 's/īn Ardhadvīpaya$//g' \
            -e 's/in \(autiomaa\|lääni\|linna\|provinssi\)$//g' \
            -e 's/is \([Mm]edie\|[Tt]sikhesimagre\)$/i/g' \
            -e 's/janski jazik$/ja/g' \
            -e 's/jas \(grāfiste\|province\)$/ja/g' \
            -e 's/jas nome$/ja/g' \
            -e 's/jos \(provincija\|pusiasalis\)$/ja/g' \
            -e 's/jos nomas$/ja/g' \
            -e 's/ko \(konderria\|probintzia\)$//g' \
            -e 's/maṇḍalam$//g' \
            -e 's/n \(kreivi\|piiri\)*kunta$//g' \
            -e 's/n dili$//g' \
            -e 's/n kieli$//g' \
            -e 's/na Rīce$//g' \
            -e 's/nag ævzag$//g' \
            -e 's/nski ezik$//g' \
            -e 's/o \(apskritis\|emyratas\|grafystė\|provincija\)$/as/g' \
            -e 's/ørkenen$/a/g' \
            -e 's/os \(pusiasalis\|vilaja\)$/as/g' \
            -e 's/s \(distrikt\|län\|nom[ae]\|rajons\)$//g' \
            -e 's/s’ka\(ya\)* \(fortetsya\|krepost\)$/a/g' \
            -e 's/s[’]*k[iy]y p\(i\|ol\)[uv]ostr[io]v$//g' \
            -e 's/sk[aá] \(říše\|župa.*\)$/sko/g' \
            -e 's/skagi$//g' \
            -e 's/skaya oblast[’]*$/sk/g' \
            -e 's/ske \(gŏdki\|rěče\)$/ska/g' \
            -e 's/ski sayuz$//g' \
            -e 's/skiy kaganat$/iya/g' \
            -e 's/vsk[ai] [Pp]lanin[ai]$/vo/g' \
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
            -e 's/^D '"${P_REGION}"' //g' \
            -e 's/^\('"${COMMON_PATTERNS}"'\)\s\s*\(\([dl]*[aeiou]*[l]*\|of\|ng\|[Tt]a\|[Tt]o[uy]\|w\)[ '"'"']\)*//g' \
            -e 's/^\(Ar[c]*hip[eè]la\(g[ou][l]*\)*\|Aut[oó]noma\|[Cc]ollegio\|[CcKk]omita[a]*t\(us\)*\|[Dd][eήḗ]mos\|[Dd]i[eoó]c[eè][sz][eij][as]*\|[Dd][ei]part[ai]*ment[ou]*[l]*\|[Dd][ií]mos\|[Ff]ort[e]*\|[GgHh]rad\|[Gg]r[aoó][a]*f\(ov\)*\(ija\|lando\|s\(ch\|k\)a\(ft\|p\)\|stvo\)\|Jangwa\|[Kk][eoö]ni[n]*[gk]r[e]*[iy][cej]*[hk]\\|[Kk][o]*r[aáo]l[io]vstv[iío]\|[Mm][ou][u]*nt[aei]*\([gi][ln][e]*\)*\|Municipi\(u[lmo]\)*\|N[iío][ms][ío][s]*\|[Oo]kr[aeęo][zž]*[gj][e]*\|[Pp]ar[r]*o[i]*\(cc\|q\|ss\)\(e\|[hu]ia\)\|[Pp][ao][luŭ][uv]ostr[ao][uŭv]\|[Pp][eé]n[iíì][n]*[csz][ou][lł][aāe]\|Periferi[j]*a\|[Rr]egatul\|[Rr]eialme\|R[iīí][fo]\|Sultanat\) \(\([dl]*[aeiou]*[l]*\|of\|ng\|[Tt]a\|[Tt]o[uy]\|w\)[ '"'"']\)*//g' \
            -e 's/^\(Āltepētl\|Ardal\|Bahasa\|Bán đảo\|Bldīẗ\|Bogserbåten\|Bundestagswahlkreis\|Bwrdeistref\|Burg\|Cathair\|Comitatu[ls]\|Daerah\|Ḍāḥīẗ\|Dorerit\|Drevna\|Emirlando\|Eparchía\|Fiume\|G[e]*m[ei][e]*n[t]*[ae]*\|Glṓssa\|Glùm Paā-săā\|Grad\|Gurun\|Hrafstvo\|Hạt\|Higashi\|Horad\|[Hh]ra[bf]stv[aí]\|Huyện\|[Ii]dioma\|Ìpínlẹ̀\|Iqlīm\|Is[ṭt][a]*\|Isŭt’ŭ\|[Jj]ęzyk\|Kàēyt Bpòk Kraāwng\|K'"'"'alak'"'"'i\|Kástro\|Kêr\|Kerajaan\|Komēteía\|Kongedømmet\|Kontelezh\|Kraljestvo\|Kreis\|Kwáāen\|Kr[aó]l[j]*e\(stwo\|vina\)\|Landschaft\|Lâu đài\|[Ll][eií][mn][g]*[bu]*a\|Lien\|Lutherstadt\|Mâāe Náām\|Markgrafschaft\|Mdīnẗ\|M[e]*ch[e]*wz\|Memlekt\|Mḥāfẓẗ\|Miedźje\|Mon-ton\|Mqāṭʿẗ\|Mu‘tamadīyat\|Ná[-]*kaāwn\|Nhr\|O[bp]\(s[hj]\|š\)tina\|Okres\|Oraș\(ul\)*\|Óros\|Paā-săā\|Pasiolak\|Perbandaran\|Pentadbiran\|Półwysep\|Potamós\|Prikhod\|Pulau\|Pustynia\|Qarku\|Raka\|Rát\|Râāt-chá-aā-naā-zhàk\|[Rr]âul\|Sa mạc\|Schloss\|Sir\|Sông\|Stadt\(kreis\)*\|Sungai\|Swydd\|ti\|[Tt]iếng\|Tỉnh\|Titularbistum\|[Tt]yrt\|Ūlāīẗ\|[Vv]ioska\|[VvWw]il[l]*a\(yah\)*\|Vilojati\|Vostraŭ\|Vương quốc\|Wikang\|Zam[eo]k\|Zhang Wàt\|Z[iı]wanê\) \(\([Tt]o[uy]\|w\) \)*//g' \
            -e 's/^\(Chetsey H'"'"'y\|Kâāp-sà-mùt\|Khu vực\|Jimbo ya\|Lalawigan ng\|Marz\|Mkoa wa\|Penrhyn y\|Talaith\|Tawilayt n\|Tighrmt n\Vostraŭ\||W[iı]lay\(a\|ah\|etê\)\) \(\(de\|ya\) \)*//g' \
            -e 's/^\(Autonome Gemeinschaft\|Bprà[ -][Tt]âēyt\|Com[m]*unitate[a]* Autonom[aăe]\|Ilang ng\|Kreisfreie Stadt\|Nhóm ngôn ngữ\|Săā-taā-rá-ná-rát\|[Tt]âēyt[ -][Mm]on[ -][Tt]on\|Tá[ -][Ll]aēy[ -][Ss]aāi\|Thị trấn\|Unitat perifèrica de\)[ -]//g' \
            -e 's/^\(Bisbat\|Bishopric\|\([CcÇçSs]\|Tz\)[eiy][uv]*[dt]*[aáàæ][dt]*[e]*[a]*\|[CcSs]\(ee\|i\)[t]*[aàey]\|[CcKk]o[mn][dt]\(a[dt][o]*\|[eé]\)\|[CcKk][aāo]*[uv]*[nṇ][tṭ][iīy][e]*\|Dakbayan\|Dēmokratía\|[Dd][eé]part[aei]m[ei]*nt[ou]*[l]*\|[Dd][eéi][sz][iy]*er[tz][ho]*\|Fort\(aleza\|ress\)\|[JjŽž]ud[iz]*e[ctțţ]\(ul\)*\|Kaharian\|Kingdom\|M[a]*ml[u]*k[a]*ẗ\|Parish\|Pr[ei]n[cgs][ei]p[aáà][dt]*[eou]*\|[Rr][eo][giy][an][eou][m]*[e]*\|R[ei][s ]*p[auüùú]b[b]*l[ií][ck][ck]*\([ai]\|en\|i\)*\|[Ss]hahrest[aā]n\\|Thành\|[Tt][h]*[eé]ma\|[Tt]zountéts\|[VvWw]il[l]*[ae]\(ya\)*\|Xian\) \('"'"'e \|d'"'"'\|[dsty][aeiîu][l]* \|[eë]d \|han \|ng \|[Tt]*[Oo][fuy]* \|phố \)*//g' \
            \
            -e 's/\(.\)\(bjerget\|shān\|sŏng\)$/\1/g' \
            -e 's/[ ’-]\([Aa]dası\|AG\|[Aa]imag\|[Aa]irurando\|aju\|alue\|[Aa]ñcala\|[Aa]ntic[aă]\|apskritis\|åsene\|[Bb]ar[ou]n[iy][am]*[u]*\|barrutia\|[Bb]hasa\|[Bb]ibhāga\|Bikéyah\|[Bb]isped[øo]m[m]*e\|[Bb]ölgesi\|Bnakavayr\|[Cc]alabro\|çayı\|Chê\|chéng[-]*bǎo\|Chhī\|Chibang\|Chiu\|[Cc]hū-tī\|Cit[t]*[aày]\|[CcKk][aāo]*[uv]*[nṇ][tṭ]\([iīy]\|lu[gğ]u]\)\|[cs]h[h]*[ìī]\|Chihō\|[Cc]hiku\|Chiyŏk\|Çölü\|[CcKk]omita[a]*t\(us\)*\|Cumhuriyeti\|[Dd]a[gğ][iı]\|[Dd]ǎo\|dar[ij]a\|Darussalam\|[Dd]evleti\|[Dd]esert\|Dġyak\|Dhāma\|Dimos\|Dzongkhag\|Eḍāri\|[Ee]ennâmkodde\|[Ee]na\|Enez\|[Ee]rusutaa\|[Ee]yaleti\|[Ff]örsamling\|[Ff]ort[e]*\|[Gg]aṇarājya\|[Gg]awa\|gielda\|[Gg]o\|[Gg]ōng[ -][Hh]é[ -][Gg]uó\|[Gg]overnorate\|[Gg]rad[ŭ]*\|grubu\|guovlu\|Hahoodzo\|[Hh]albinsel\|hálvoyggin\|Hantou\|He\|Hyŏn\|[Ii]baia\|[Ii]ngurando\|[Jj]ach'"'"'a\|[Jj]anarajaya\|jõgi\|[Jj][iù]n\|jūnōu\|[Kk]a [KkQq]ila\|kaavpug\|ǩalaḥy\|[Kk]alāpaya\|[Kk]alni\|Kang\|Kàēyt Brì Hăān Pí Sàēyt\|kansallispuisto\|[Kk]àu-khu\|ke[e]*l['"'"']*\|[Kk]hiung[ -][Ff]ò[ -][Kk]oet\|[Kk]örzet\|\|[Kk]ōṭṭai\|khoig\|[Kk]hot\|[Kk]hu\|[Kk][iy][i]*l\|Kilisesi\|Kingdom\|[Kk]o[aā]n\|Koku\|[Kk]onderria\|község\|[Kk]rallığı\|[Kk]repost\|[Kk]shetr\|Kūn\|Kyouku\|Kyouwa Koku\|lääni\|[Ll]anguage\|[Ll]ingvo\|linn\|maak[ou]n[dt]a*\|[Mm]achi\|[Mm]ahal[iı]\|Mākāṇam\|Mānakaram\|Maṇḍalam\|Marubhūmi\|Māvaṭṭam\|[Mm]arz\|[Mm]e[dg][iy]e\|mhuriyeti\|[Mm]oḻi\|[Mm]ovy\|[Mm]unicipality\|Mura\|Nadi\|Nagar\(am\)*\|Nakaram\|Nakhevark[’]*undzuli\|[Nn]aturreservat\|Nehri\|Nisí\|osariik\|[Oo]ukoku\|o’zeni\|pagasts\|[Pp]akuti\|[Pp]aḷāta\|Pālaivaṉam\|[Pp]ats’alyg’y\|[Pp]il[i]*s\|piirkonnaüksus\|poolsaar\|qalas[iıy]\|qəsri\|qraflığı\|[Rr]ajonas\|rén\|[Rr]e[s]*publi[ck][a]*\(ḥy\)*\|[Rr]iver\|[SsŠš]aar[iy]*\|Sa[bm]ak[u]*\|[Ss]agrapo\|[sșş][eə]hristan[iı]\|[Ss][h]*i\|Shikyou Ryou\|Shinrinkouen\|[Ss][ho][aā]-[bm][òô͘]*\|[Ss]hou\|Siti\|Shuu\|síksá\|sivatag\|slott\|so\(g\|cke\)n\|sritis\|Sṳ\|sultan\(at[e]*\|lığı\)\|suohkan\|suyu\|tamaneɣt\|[Tt][’]*erakġzi\|tartomány\|[Tt][eē]\|tele\|[Tt]hi-[Kk]hî\|tillari\|[Tt]oshi\|[Tt][oō][au]*\|Town\|tu’begi\|[Uu]da\(bno\|lerria\)\|vald\\|[Vv]ibhāg\|Viru\|VS\|Vương quốc Hồi giáo\|[Ww]amani\|[Ww]áng[ -][Gg]uó\|Wangguk\|[Xx]i[aàā]n[g]*\|[Yy]arımadası\|yǔ\|zh[ēō]*[nu]\|[ZzŽž][h]*ude[ct]s[i]*\|zōng\)$//g' \
            -e 's/[ ’-]\([CcKk]o[ou]*nt\(ae\|luğu\|y\)\|[Dd]epart[a]*ment\(as\)*\|Durg[a]*\|[EeIi]*[Ss][h]*t[’]*a[dt][’]*[eiou]\|[Ff]ort[r]*e[t]*s[s]*[y]*[a]*\|[Ff]ylk[ei]\|[GgQq]r[aā]f[l]*[iı]\(ı\|ste\)\|\|[Jj][eēi]l[hl]*[aāeo][a]*\|[Jj][oō][u]*\|[Kk]il[l]*[ao]\|[Mm]a[nṇ][dḍ]al\(a[mṁ]\)*\|Muni\(c\|ts\)ip[’]*alit[’]*\(et’i\|y\)\|[Nn]ahan[gk]\|P[aā][i]*ri\(ṣ\|sh\)\|[Mm]in[tţ]a[kq]at*\|[Oo]blas[tť]\|[Pp][ao][luŭ][uv]ostr[ao][uŭv]\|[Pp][eé]n[iíì][n]*[csz][ou][lł][aāe]\|[Pp]ii\(r\|skop\)kond\|[Pp]lanin[ai]\|[Pp]r[a]*d[eē][sś][h]*[a]*\|[Pp]r[aā]*nt[y]*[a]*\([ṁy][a]*\)*\|[Pp]rja[a]*st[t]*a[a]*k\|[Pp]u[u]*[l]*s[s]*a[al][ar]\|[Rr]eialme\|[Rr][e]*[iī]c[eh]\|[Rr]esp[uúy][’]*bli[’]*[ck][ai]\(sy\)*\|[Ss]h[eě]ng\|[Vv]il[aā][jy]\(eti\|s\)\|[ZzŽž]upa\(nija\)*\)$//g' \
            -e 's/[ ’-]\('"${COMMON_PATTERNS}"'\)$//g' \
            -e 's/ [KkCc]om*un*[ea]*$//g' \
            -e 's/ \(Ken\|Koān\)$//g' \
            \
            -e 's/^Hl\. /Heilige /g' \
            -e 's/ mfiadini$/ Mfiadini/g' \
            \
            -e 's/^\(Abhainn\|Afon\|Ri[ou]\) //g' \
            -e 's/^\(Ducado\|Reinu\) de l'"\'"'//g' \
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

        if [ "${LANGUAGE_CODE}" != "ar" ] && \
           [ "${LANGUAGE_CODE}" != "ga" ] && \
           [ "${LANGUAGE_CODE}" != "jam" ] && \
           [ "${LANGUAGE_CODE}" != "jbo" ]; then
            NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^\([a-z]\)/\U\1/g')
        fi

        [ "${LANGUAGE_CODE}" == "lt" ]  && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^Šv\./Šventasis/g')
        [ "${LANGUAGE_CODE}" == "zh" ]  && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/-//g')
        [ "${LANGUAGE_CODE}" == "ang" ] && NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/enrice$/e/g')

        NORMALISED_NAME=$(echo "${NORMALISED_NAME}" | sed 's/^L'"'"'/l'"'"'/g')

        echo "${NORMALISED_NAME}"
}

function nameToLocationId() {
    local NAME="${1}"

    echo "${NAME}" | \
        sed -e 's/\([ČčŠšŽž]\)/\1h/g' | \
        sed -e 's/[Ǧǧ]/j/g' | \
        iconv -f utf8 -t ascii//TRANSLIT | \
        sed 's/-le-/_le_/g' | \
        sed 's/ /_/g' | sed "s/\'//g" | \
        sed 's/['"\'"']//g' | sed "s/\'//g" | \
        sed 's/\(north\|west\|south\|east\)ern/\1/g' | \
        sed 's/^\(north\|west\|south\|east\)_\(.*\)$/\2_\1/g' | \
        tr '[:upper:]' '[:lower:]'
}
