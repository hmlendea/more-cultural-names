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
            -e 's/’i\(bando\|sŏm\)$/’i/g' \
            -e 's/[gk]iel[l]*[aâ]$//g' \
            -e 's/\(n\|ṉ\) [Pp]e\(n\|[ṉ]*\)i\(n\|[ṉ]*\)[cs]ulā$//g' \
            -e 's/^D //g' \
            -e 's/^Dēmokrhatía tou//g' \
            -e 's/^Diecezja \(.*\)ska$/\1ia/g' \
            -e 's/^języki \(.*\)skie$/\1ski/g' \
            -e 's/^Kástro tou//g' \
            -e 's/^Półwysep \(.*\)ski$/\1/g' \
            -e 's/a fylka$//g' \
            -e 's/a Śahara$//g' \
            -e 's/an Tazovaldkund$//g' \
            -e 's/an[sš]*[cćč]ina$/a/g' \
            -e 's/anis\(ch\|k\)$/a/g' \
            -e 's/ańĭskŭ językŭ$/a/g' \
            -e 's/ans[’]*ka\(ja\)* mova$/a/g' \
            -e 's/as \(vilāj[as]\|mintaka\)$/a/g' \
            -e 's/hantou$//g' \
            -e 's/i Get$//g' \
            -e 's/i ringkond$//g' \
            -e 's/i-\(félsziget\|királyság\)$//g' \
            -e 's/iin tsöl$//g' \
            -e 's/īn Ardhadvīpaya$//g' \
            -e 's/in autiomaa$//g' \
            -e 's/is [Tt]sikhesimagre$//g' \
            -e 's/janski jazik$/ja/g' \
            -e 's/jas \(grāfiste\|province\)$/ja/g' \
            -e 's/jas nome$/ja/g' \
            -e 's/jos \(provincija\|pusiasalis\)$/ja/g' \
            -e 's/jos nomas$/ja/g' \
            -e 's/ko \(konderria\|probintzia\)$//g' \
            -e 's/n \(kreivi\)*kunta$//g' \
            -e 's/n dili$//g' \
            -e 's/n kieli$//g' \
            -e 's/na Rīce$//g' \
            -e 's/nag ævzag$//g' \
            -e 's/nski ezik$//g' \
            -e 's/o \(apskritis\|emyratas\|grafystė\)$/as/g' \
            -e 's/ørkenen$/a/g' \
            -e 's/os \(vilaja\)$/as/g' \
            -e 's/s[’]*k[iy]y p\(i\|ol\)[uv]ostr[io]v$//g' \
            -e 's/skagi$//g' \
            -e 's/skaya oblast[’]*$/sk/g' \
            -e 's/ske \(gŏdki\|rěče\)$/ska/g' \
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
            -e 's/^D Regioon //g' \
            -e 's/^\(Ar[c]*hip[eè]la\(g[ou][l]*\)*\|Aut[oó]noma\|[CcKk]a[i]*st[ei]*[al][l]*[eoulm]*\|[Dd]i[eoó]c[eè][sz][eij][as]*\|[Dd][iy]str[eiy][ckt]*[akt][eouy]*[as]*\|[Ee]*[SsŠš]ta[dtu][eou]*[l]*\|[Ff]ort[e]*\|[GgHh]rad\|[Gg]r[aoó][a]*f\(ov\)*\(ija\|lando\|s\(ch\|k\)a\(ft\|p\)\|stvo\)\|[Ii][n]*[s]*[u]*l[l]*[ae]\|Jangwa\|Kongedømmet\|[Mm][ou][u]*nt[ae][gi][ln][e]*\|Municipi\(u[lmo]\)*\|[Oo]kr[aeęo][zž]*[gj][e]*\|[Pp]ar[r]*o[i]*\(cc\|q\|ss\)\(e\|[hu]ia\)\|[Pp]en[iíì][n]*[csz][ou][lł][aā]\|Periferi[j]*a\|[Pp][’]*r[ao][bpvw][ëií][nñ][t]*[csz]*[eiíjoy]*[aez]*\|[Pp]r[eé]fe[ckt]t[uū]r[ae]\|[Rr]egatul\|[Rr]eialme\|Sultanat\) \(\([dl]*[aeiou]*[l]*\|of\|ng\|[Tt]o[uy]\|w\)[ '"'"']\)*//g' \
            -e 's/^\(Āltepētl\|Ancient\|Antica\|Archaía\|Ardal\|Bahasa\|Bán đảo\|Bldīẗ\|Bogserbåten\|Bundestagswahlkreis\|Burg\|Cathair\|Comitatu[ls]\|Daerah\|Dorerit\|Drevna\|Emirlando\|Eparchía\|Fiume\|G[e]*m[ei][e]*n[t]*[ae]*\|Glṓssa\|Glùm Paā-săā\|Grad\|Gurun\|Hrafstvo\|Hạt\|Higashi\|Horad\|[Hh]ra[bf]stv[aí]\|Huyện\|[Ii]dioma\|İlçesi\|Ìpínlẹ̀\|Iqlīm\|Is[ṭt][a]*\|Isŭt’ŭ\|[Jj]ęzyk\|K'"'"'alak'"'"'i\|Kástro\|[Kk][eoö]ni[n]*[gk]r[e]*[iy][cej]*[hk]\|Kêr\|Kerajaan\|Komēteía\|Kontelezh\|Kraljestvo\|Kreis\|Kwáāen\|Kr[aó]l[j]*e\(stwo\|vina\)\|Landschaft\|Lâu đài\|[Ll][eií][mn][g]*[bu]*a\|Lutherstadt\|Markgrafschaft\|Mdīnẗ\|M[e]*ch[e]*wz\|Memlekt\|Mon-ton\|Mqāṭʿẗ\|Ná[-]*kaāwn\|Nomόs\|O[bp]\(s[hj]\|š\)tina\|Okres\|Oraș\|Paā-săā\|Pasiolak\|Pentadbiran\|Półwysep\|Potamós\|Prikhod\|Pustynia\|Qarku\|Raka\|Rát\|Râāt-chá-aā-naā-zhàk\|[Rr]âul\|R[iīí][fo]\|Sa mạc\|Schloss\|Sir\|Stadt\(kreis\)*\|Swydd\|ti\|[Tt]iếng\|Tỉnh\|[Tt]yrt\|Ūlāīẗ\|[Vv]ioska\|[VvWw]il[l]*a\(yah\)*\|Vilojati\|Vostraŭ\|Vương quốc\|Wikang\|Zam[eo]k\|Zhang Wàt\|Z[iı]wanê\) \(\([Tt]o[uy]\|w\) \)*//g' \
            -e 's/^\(Chetsey H'"'"'y\|Kâāp-sà-mùt\|Khu vực\|Jimbo ya\|Lalawigan ng\|Marz\|Mkoa wa\|Penrhyn y\|Talaith\|Tawilayt n\|Tighrmt n\Vostraŭ\||W[iı]lay\(a\|ah\|etê\)\) \(\(de\|ya\) \)*//g' \
            -e 's/^\(Autonome Gemeinschaft\|Bprà[ -][Tt]âēyt\|Com[m]*unitate[a]* Autonom[aăe]\|Ilang ng\|Kreisfreie Stadt\|Nhóm ngôn ngữ\|Săā-taā-rá-ná-rát\|[Tt]âēyt[ -][Mm]on[ -][Tt]on\|Tá[ -][Ll]aēy[ -][Ss]aāi\|Thị trấn\)[ -]//g' \
            -e 's/^\(Bisbat\|Bishopric\|\([CcÇçSs]\|Tz\)[eiy][uv]*[dt]*[aáàæ][dt]*[e]*[a]*\|[CcSs]\(ee\|i\)[t]*[aàey]\|[Cc]h[aâ]teau\|[CcKk]o[mn][dt]\(a[dt][o]*\|[eé]\)\|[CcKk][aāo]*[uv]*[nṇ][tṭ][iīy][e]*\|Dakbayan\|Dēmokratía\|[Dd][eé]part[aei]m[ei]*nt[ou]*[l]*\|[Dd][eéi][sz][iy]*er[tz][ho]*\|Fort\(aleza\|ress\)\|[JjŽž]ud[iz]*e[ctțţ]\(ul\)*\|Kaharian\|Kingdom\|M[a]*ml[u]*k[a]*ẗ\|Parish\|Pr[ei]n[cgs][ei]p[aáà][dt]*[eou]*\|[Rr]e[gģhx][ij]*[oóu][u]*n*i*[aes]*\|[Rr][eo][giy][an][eou][m]*[e]*\|R[ei][s ]*p[auüùú]b[b]*l[ií][ck][ck]*\([ai]\|en\|i\)*\|[Ss]hahrest[aā]n\|State\|Thành\|[Tt][h]*[eé]ma\|[Tt]zountéts\|[VvWw]il[l]*[ae]\(ya\)*\|Xian\) \('"'"'e \|d'"'"'\|[dsty][aeiîu][l]* \|[eë]d \|han \|ng \|[Tt]*[Oo][fuy]* \|phố \)*//g' \
            \
            -e 's/\(.\)\(bjerget\|shān\|sŏng\)$/\1/g' \
            -e 's/[ ’-]\([Aa]dası\|AG\|[Aa]imag\|[Aa]irurando\|aju\|alue\|[Aa]ñcala\|apskritis\|åsene\|[Bb]ar[ou]n[iy][am]*[u]*\|[Bb]hasa\|[Bb]ibhāga\|Bikéyah\|[Bb]isped[øo]m[m]*e\|[Bb]ölgesi\|[Cc]alabro\|[Cc]astle\|çayı\|Chê\|chéng[-]*bǎo\|Chhī\|Chibang\|Chiu\|[Cc]hū-tī\|Cit[t]*[aày]\|[CcKk][aāo]*[uv]*[nṇ][tṭ]\([iīy]\|lu[gğ]u]\)\|[cs]h[h]*[ìī]\|[Cc]hiku\|Chiyŏk\|Çölü\|[Cc]omitatus\|Cumhuriyeti\|[Dd]a[gğ][iı]\|[Dd]ǎo\|dar[ij]a\|Darussalam\|[Dd]evleti\|[Dd]esert\|Dġyak\|Dhāma\|Dzongkhag\|Eḍāri\|[Ee]ennâmkodde\|[Ee]na\|[Ee]rusutaa\|[Ee]yaleti\|[Ff]örsamling\|[Ff]ort[e]*\|[Ff]ylke\|[Gg]aṇarājya\|[Gg]awa\|gielda\|[Gg]o\|[Gg]ōng[ -][Hh]é[ -][Gg]uó\|[Gg]overnorate\|[Gg]rad[ŭ]*\|grubu\|guovlu\|Hahoodzo\|hálvoyggin\|Hantou\|He\|Hyŏn\|[Ii]ngurando\|[Ii]sland\|[Jj]ach'"'"'a\|[Jj]anarajaya\|jõgi\|[Jj][iù]n\|jūnōu\|[Kk]a [KkQq]ila\|kaavpug\|ǩalaḥy\|[Kk]alāpaya\|[Kk]alni\|Kang\|Kàēyt Brì Hăān Pí Sàēyt\|[Kk]àu-khu\|ke[e]*l['"'"']*\|[Kk]hiung[ -][Ff]ò[ -][Kk]oet\|[Kk]örzet\|\|[Kk]ōṭṭai\|khoig\|[Kk]hot\|[Kk]hu\|[Kk][iy][i]*l\|Kilisesi\|Kingdom\|[Kk]o[aā]n\|[Kk]onderria\|község\|[Kk]rallığı\|[Kk]shetr\|Kūn\|Kyouku\|Kyouwa Koku\|[Ll]anguage\|[Ll]ingvo\|linn\|maak[ou]n[dt]a*\|[Mm]achi\|[Mm]ahal[iı]\|Mākāṇam\|Mānakaram\|Maṇḍalam\|Marubhūmi\|Māvaṭṭam\|[Mm]arz\|megye\|mhuriyeti\|[Mm]oḻi\|[Mm]ovy\|[Mm]unicipality\|Mura\|Nadi\|Nagar\(am\)*\|Nakaram\|Nakhevark[’]*undzuli\|[Nn]aturreservat\|Nehri\|osariik\|[Oo]ukoku\|pagasts\|[Pp]akuti\|[Pp]aḷāta\|Pālaivaṉam\|[Pp]ats’alyg’y\|[Pp]il[i]*s\|[Pp]oluostrov\|[Pp]refe[ck]t[uú]r[ae]\|qalas[iıy]\|qəsri\|qraflığı\|[Rr]ajonas\|[Rr]e[gh]i[j]*on\|rén\|[Rr]e[s]*publi[ck][a]*\(ḥy\)*\|[Rr]iver\|[SsŠš]aar[iy]*\|Sa[bm]ak[u]*\|[Ss]agrapo\|[sșş][eə]hristan[iı]\|[Ss][h]*i\|Shikyou Ryou\|Shinrinkouen\|[Ss][ho][aā]-[bm][òô͘]*\|[Ss]hou\|Siti\|Shuu\|síksá\|sivatag\|slott\|so\(g\|cke\)n\|sritis\|Sṳ\|sultan\(at[e]*\|lığı\)\|suohkan\|suyu\|tamaneɣt\|[Tt][’]*erakġzi\|tartomány\|[Tt][eē]\|tele\|[Tt]hi-[Kk]hî\|tillari\|[Tt]oshi\|[Tt][oō][au]\|Town\|tu’begi\|[Uu]da\(bno\|lerria\)\|vald\|[Vv]ibhāg\|Viru\|VS\|Vương quốc Hồi giáo\|[Ww]amani\|[Ww]áng[ -][Gg]uó\|Wangguk\|[Xx]i[aàā]n[g]*\|[Yy]arımadası\|yǔ\|zh[ēō]*[nu]\|[ZzŽž][h]*ude[ct]s[i]*\|zōng\)$//g' \
            -e 's/[ ’-]\([CcKk]o[ou]*nt\(ae\|luğu\|y\)\|[Dd]epart[a]*ment\(as\)*\|[Dd][iy]str[eiy][ckt]*[akt][eouy]*[as]*\|Durg[a]*\|[EeIi]*[Ss][h]*t[’]*a[dt][’]*[eiou]\|[GgQq]r[aā]f[l]*[iı]\(ı\|ste\)\|\|[Jj][eēi]l[hl]*[aāeo][a]*\|[Jj][oō][u]*\|[Kk]il[l]*[ao]\|[Mm]a[nṇ][dḍ]al\(a[mṁ]\)*\|Muni\(c\|ts\)ip[’]*alit[’]*\(et’i\|y\)\|P[aā][i]*ri\(ṣ\|sh\)\|[Mm]in[tţ]a[kq]at*\|[Oo]blas[tť]\|[Pp]en[ií]n[cs]ul[aā]\|[Pp]ii\(r\|skop\)kond\|[Pp]lanin[ai]\|[Pp]r[a]*d[eē][sś][h]*[a]*\|[Pp]r[aā]*nt[y]*[a]*\([ṁy][a]*\)*\|[Pp][’]*r[aāou][bpvw][ëií][nñ][t]*[csz]*[eėiíjoy]*[aeėsz]\|[Pp]r[eé]fe[ckt]t[uū]r[ae]\|[Pp]rja[a]*st[t]*a[a]*k\|[Pp]u[u]*[l]*s[s]*a[al][ar]\|[Rr]e[gģh]i[j]*\([oóu]n*[ei]*[as]*\|st[aā]n\)\|[Rr]eialme\|[Rr][e]*[iī]c[eh]\|[Rr]esp[uúy][’]*bli[’]*[ck][ai]\(sy\)*\|[Ss]h[eě]ng\|[Ss][h]*t[’]*at[’]*[ei]\|[Vv]il[aā][jy]\(eti\|s\)\)$//g' \
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
        iconv -f utf8 -t ascii//TRANSLIT | \
        sed 's/-le-/_le_/g' | \
        sed 's/ /_/g' | sed "s/\'//g" | \
        sed 's/['"\'"']//g' | sed "s/\'//g" | \
        sed 's/\(north\|west\|south\|east\)ern/\1/g' | \
        sed 's/^\(north\|west\|south\|east\)_\(.*\)$/\2_\1/g' | \
        tr '[:upper:]' '[:lower:]'
}
