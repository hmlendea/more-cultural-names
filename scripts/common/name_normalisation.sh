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
    local P_CASTLE="[CcGgKk]a[i]*[sz][lt][ei]*[aál][il]*[eoulmn]*[a]*\|[Cc]h[aâ]teau\|Dvorac\|[Kk]alesi\|Zam[ao][gk][y]*"
    local P_CATHEDRAL="[CcKk]at[h]*[eé]dr[ai][kl][aeoó]*[s]*"
    local P_CITY="[CcSs]\(ee\|i\)[tṭ][tṭ]*[aàeiy]\|Nagara\|Oraș\(ul\)*\|Śahara\|Sich’i"
    local P_COUNCIL="[Cc]o[u]*n[cs][ei]l[l]*\(iul\)\|[Cc]omhairle"
    local P_COUNTRY="[Nn]egeri"
    local P_DEPARTMENT="[Dd][eéi]p[’]*art[’]*[aei]*m[aei][e]*n[gt][’]*\(as\|i\|o\|u[l]*\)*"
    local P_DISTRICT="[Dd][iy]str[eiy][ckt]*[akt][eouy]*[as]*\|[Iiİi̇]l[cç]esi\|járás\|Quận\|sum"
    local P_FORT="\([CcKk][aá]str[aou][lm]*\|[Ff]ort\(e\(tsya\)*\|ul\)*\|[Ff]ort\(aleza\|[e]*ress[e]*\)\|[Ff]ort[r]*e[t]*s[s]*[y]*[ae]*\|[Kk]repost\|[Tv]rdina\)\( \(roman\|royale\)\)*"
    local P_GMINA="[Gg][e]*m[e]*in[d]*[ae]"
    local P_HUNDRED="[Hh][äe]r[r]*[ae]d\|[Hh]undred\|[Kk]ihlakunta"
    local P_ISLAND="[Ǧǧ]zīrẗ\|[Ii]nsula\|[Ii]sl[ae]\|[Ii]sland\|[Nn][eḗ]sos\|Sŏm"
    local P_KINGDOM="guó\|[Kk][eoö]ni[n]*[gk]r[e]*[iy][cej]*[hk]\|K[io]ng[e]*d[oø]m\(met\)*\|[Kk]irályság\|[Rr]egatul\|[Rr][eo][giy][an][eolu][m]*[e]*\|[Rr]īce"
    local P_LAKE="Gölü\|[Ll]a\(c\|cul\|go\|ke\)\|[Nn][uú][u]*r\|[Oo]zero"
    local P_LANGUAGE="[Ll]anguage\|[Ll][eií][mn][g]*[buv]*[ao]"
    local P_MOUNTAIN="[GgHh][ao]ra\|[Mm][ouū][u]*nt[aei]*\([gi]*[ln][e]*\)*\|[Pp]arvata[ṁ]*\|San"
    local P_MONASTERY="[Kk]lo[o]*ster\(is\)*\|[Mm][ăo]n[aăe]st[eèi]r\(e[a]*\|i\|io[a]*\|o\|y\)*\|[Mm]onaĥejo\|[Mm]osteiro\|[Ss]hu[u]*dōin"
    local P_MUNICIPIUM="[Bb]elediyesi\|Chibang Chach’ije\|Đô thị tự trị\|[Kk]ong-[Ss]iā\|[Kk]otamadya\|[Mm]eūang\|[Mm][y]*un[i]*[t]*[cs]ip[’]*\([aā]*l[i]*[dtṭ][’]*\(a[ds]\|é\|et’i\|[iī]\|y\)\|i[ou][lm]*\)\|[Nn]agara [Ss]abhāva\|[Nn]a[gk][a]*r[aā]\(pālika\|ṭci\)\|O[bp]\(č\|s[hj]\|š\)[t]*ina\|[Pp]ašvaldība\|[Pp][a]*urasabh[āe]\|[Ss]avivaldybė"
    local P_NATIONAL_PARK="[Nn]ational [Pp]ark\|Par[cq]u[el] Na[ctț]ional\|[Vv]ườn [Qq]uốc"
    local P_OASIS="[aā]l-[Ww]āḥāt\|[OoÓóŌō][syẏ]*[aáāeē][sz][h]*[aiīeėē][ans]*[uŭ]*\|Oūh Aēy Sít"
    local P_PENINSULA="[Bb][aá]n[ ]*[dđ][aả]o\|[Dd]uoninsulo\|[Hh]antō\|[Nn]iemimaa\|[Pp][ao][luŭ][ouv]ostr[ao][uŭv]\|[Pp][eé]n[iíì][n]*[t]*[csz][ou][lł][aāe]\|Poàn-tó\|[Ss]emenanjung\|[Yy]arim [Oo]roli\|[Yy]arımadası\|[Žž]arym [Aa]raly"
    local P_PREFECTURE="[Pp]r[aäeé][e]*fe[ckt]t[uúū]r[ae]*"
    local P_PROVINCE="[Pp][’]*r[aāou][bpvw][ëií][nñ][t]*[csz]*[eėiíjoy]*[aeėsz]*"
    local P_REGION="[Rr]e[gģhx][ij]*\([oóu][ou]*n*[ei]*[as]*\|st[aā]n\)"
    local P_REPUBLIC="D[eēi]mokr[h]*atía\|Köztársaság\|Olómìnira\|[Rr][eéi][s]*[ ]*p[’]*[auüùúy][’]*b[b]*l[ií][ckq][ck]*[’]*\([ai]\|as[ıy]\|en\|[hḥ]y\|i\|ue\)*"
    local P_RUIN="[Rr]uin[ae]*"
    local P_STATE="Bang\|[EeÉé]*[SsŜŝŜŝŠšŞş]*[h]*[tṭ][’]*[aeē][dtṭu][’]*[aeiıosu]*[l]*\|[Oo]st[’]*an[ıi]\|[Uu]stoni\|valstija*"
    local P_TEMPLE="[Dd]ēvālaya\(mu\)*\|[Kk]ōvil\|[Mm][a]*ndir[a]*\|Ná Tiān\|[Pp]agoda\|[Tt]emp[e]*l[eou]*[l]*"
    local P_TOWNSHIP="[CcKk]anton[ae]*\(mendua\)*\|[Tt]ownship"

    local P_OF="\([dl]*[aeiou]*[l]*\|gia\|of\|ng\|[Tt]a\|[Tt]o[uy]\|van\|w\)[ '\"'\"']"

    local COMMON_PATTERNS="${P_ANCIENT}\|${P_CASTLE}\|${P_CATHEDRAL}\|${P_CITY}\|${P_COUNCIL}\|${P_COUNTRY}\|${P_DEPARTMENT}\|${P_DISTRICT}\|${P_FORT}\|${P_GMINA}\|${P_HUNDRED}\|${P_ISLAND}\|${P_KINGDOM}\|${P_LAKE}\|${P_P_LANGUAGE}\|${P_MONASTERY}\|${P_MOUNTAIN}\|${P_MUNICIPIUM}\|${P_NATIONAL_PARK}\|${P_OASIS}\|${P_PENINSULA}\|${P_PREFECTURE}\|${P_PROVINCE}\|${P_REGION}\|${P_REPUBLIC}\|${P_RUIN}\|${P_STATE}\|${P_TEMPLE}\|${P_TOWNSHIP}"

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
            -e 's/'"’"'agang$/’a/g' \
            -e 's/’i\(bando\|sŏm\)$/’i/g' \
            -e 's/[gk]iel[l]*[aâ]$//g' \
            -e 's/\(hyŏn\|sŏm\)$//g' \
            -e 's/\(n\|ṉ\) [Pp]e\(n\|[ṉ]*\)i\(n\|[ṉ]*\)[cs]ulā$//g' \
            -e 's/^[Dd][eḗií]mos \(.*\)oú$/\1ós/g' \
            -e 's/^D //g' \
            -e 's/^Diecezja \(.*\)ska$/\1ia/g' \
            -e 's/^języki \(.*\)skie$/\1ski/g' \
            -e 's/^Półwysep \(.*\)ski$/\1/g' \
            -e 's/a \(fylka\|Śahara\)$//g' \
            -e 's/an Tazovaldkund$//g' \
            -e 's/an[sš]*[cćč]ina$/a/g' \
            -e 's/anis\(ch\|k\)$/a/g' \
            -e 's/ańĭskŭ językŭ$/a/g' \
            -e 's/ans[’]*ka\(ja\)* mova$/a/g' \
            -e 's/as \(vilāj[as]\|mintaka\|meģe\)$/a/g' \
            -e 's/es \('"${P_MONASTERY}\|${P_MUNICIPIUM}"'\)$/a/g' \
            -e 's/ės \('"${P_MUNICIPIUM}"'\)$/ė/g' \
            -e 's/bàn$//g' \
            -e 's/halvøen$//g' \
            -e 's/hantou$//g' \
            -e 's/hú$//g' \
            -e 's/i[ -]\('"${P_DEPARTMENT}"'félsziget\|[Gg]et\|lään\|ringkond\)$//g' \
            -e 's/iin tsöl$//g' \
            -e 's/in \('"${P_HUNDRED}\|${P_PROVINCE}"'\|autiomaa\|lääni\|linna\|niemimaa\)$//g' \
            -e 's/īn Ardhadvīpaya$//g' \
            -e 's/is \([Mm]edie\|[Tt]sikhesimagre\)$/i/g' \
            -e 's/janski jazik$/ja/g' \
            -e 's/jas \('"${P_HUNDRED}\|${P_PROVINCE}"'\|grāfiste\|nome\)$/ja/g' \
            -e 's/jos \('"${P_OASIS}\|${P_PROVINCE}"'\|nomas\|pusiasalis\)$/ja/g' \
            -e 's/ko \('"${P_MONASTERY}\|${P_PROVINCE}"'\|konderria\)$//g' \
            -e 's/maṇḍalam$//g' \
            -e 's/n \(kreivi\|piiri\)*kunta$//g' \
            -e 's/n dili$//g' \
            -e 's/n kieli$//g' \
            -e 's/na \('"${P_KINGDOM}"'\)$//g' \
            -e 's/nag ævzag$//g' \
            -e 's/nski ezik$//g' \
            -e 's/nūrs$//g' \
            -e 's/o \(apskritis\|emyratas\|grafystė\|provincija\)$/as/g' \
            -e 's/o[s]* \(pusiasalis\|vilaja\)$/as/g' \
            -e 's/ørkenen$/a/g' \
            -e 's/s \('"${P_DISTRICT}\|${P_HUNDRED}"'\|län\|nom[ae]\|rajons\)$//g' \
            -e 's/s’ka\(ya\)* \('"${P_FORT}"'\)$/a/g' \
            -e 's/s[’]*k[iy]y p\(i\|ol\)[uv]ostr[io]v$//g' \
            -e 's/shitii$//g' \
            -e 's/sk[aá] \(poušť\|říše\|župa.*\)$/sko/g' \
            -e 's/sk[iý] \('"${P_PENINSULA}"'\|sayuz\)$//g' \
            -e 's/skagi$//g' \
            -e 's/skaya oblast[’]*$/sk/g' \
            -e 's/ske \(gŏdki\|rěče\)$/ska/g' \
            -e 's/skiy kaganat$/iya/g' \
            -e 's/vsk[ai] [Pp]lanin[ai]$/vo/g' \
            -e 's/x žudecs$/a/g' \
            -e 's/ý polostrov$/o/g' \
            -e 's/yanskiy[e]* \(yazyk[i]*\)$/ya/g' \
            -e 's/yn khoig$//g' \
            \
            -e 's/\('"${P_KINGDOM}"'\|'"${P_OASIS}"'\)$//g' \
            \
            -e 's/^\(Byen\|Dinas\|Ìlú\|Mbanza ya\|Sita\|Syudad han\) //g' \
            -e 's/^Co[ou]*nt\(ae\|ea\|y\) \(d[ei] \|of \)*//g' \
            -e 's/^Con[dt][aá]d*[eou] \(d[eo] \)*//g' \
            -e 's/^Comt[aé]t* de //g' \
            -e 's/^[CcKk]om*un*[ea]*[n]* //g' \
            -e 's/^D '"${P_REGION}"' //g' \
            -e 's/^\('"${COMMON_PATTERNS}"'\)\s\s*\('"${P_OF}"'\)*//g' \
            -e 's/^\(Ar[c]*hip[eè]la\(g[ou][l]*\)*\|Aut[oó]noma\|[Cc]ollegio\|[CcKk]omita[a]*t\(us\)*\|[Dd][eήḗ]mos\|[Dd]i[eoó]c[eè][sz][eij][as]*\|[Dd][ií]mos\|[GgHh]rad\|[Gg]r[aoó][a]*f\(ov\)*\(ija\|lando\|s\(ch\|k\)a\(ft\|p\)\|stvo\)\|Jangwa\[Kk][o]*r[aáo]l[io]vstv[iío]\|N[iío][ms][ío][s]*\|[Oo]kr[aeęo][zž]*[gj][e]*\|[Pp]ar[r]*o[i]*\(cc\|q\|ss\)\(e\|[hu]ia\)\|Periferi[j]*a\|R[iīí][fo]\|Sultanat\) \('"${P_OF}"'\)*//g' \
            -e 's/^\(Āltepētl\|Ardal\|Bahasa\|Bldīẗ\|Bogserbåten\|Bundestagswahlkreis\|Bwrdeistref\|Burg\|Cathair\|Comitatu[ls]\|Daerah\|Ḍāḥīẗ\|Dorerit\|Drevna\|Emirlando\|Eparchía\|Fiume\|G[e]*m[ei][e]*n[t]*[ae]*\|Glṓssa\|Glùm Paā-săā\|Grad\|Gurun\|Hrafstvo\|Hạt\|Higashi\|Horad\|[Hh]ra[bf]stv[aí]\|Huyện\|[Ii]dioma\|Ìpínlẹ̀\|Iqlīm\|Is[ṭt][a]*\|Isŭt’ŭ\|[Jj]ęzyk\|Kàēyt Bpòk Kraāwng\|K'"'"'alak'"'"'i\|Kêr\|Kerajaan\|Komēteía\|Kontelezh\|Kraljestvo\|Kreis\|Kwáāen\|Kr[aó]l[j]*e\(stwo\|vina\)\|Landschaft\|Lâu đài\|Lien\|Lutherstadt\|Mâāe Náām\|Markgrafschaft\|Mdīnẗ\|M[e]*ch[e]*wz\|Memlekt\|Mḥāfẓẗ\|Miedźje\|Mnṭqẗ\|Mon-ton\|Mqāṭʿẗ\|Mu‘tamadīyat\|Ná[-]*kaāwn\|Nhr\|Okres\|Óros\|Paā-săā\|Pasiolak\|Perbandaran\|Pentadbiran\|Półwysep\|Potamós\|Prikhod\|Pulau\|Pustynia\|Qarku\|Raka\|Rát\|Râāt-chá-aā-naā-zhàk\|[Rr]âul\|Sa mạc\|Schloss\|Sir\|Sông\|Stadt\(kreis\)*\|Sungai\|Swydd\|ti\|[Tt]iếng\|Tỉnh\|Titularbistum\|[Tt]yrt\|Ūlāīẗ\|[Vv]ioska\|[VvWw]il[l]*a\(yah\)*\|Vilojati\|Vostraŭ\|Vương quốc\|Wikang\|Zam[eo]k\|Zhang Wàt\|Z[iı]wanê\) \('"${P_OF}"'\)*//g' \
            -e 's/^\(Chetsey H'"'"'y\|Kâāp-sà-mùt\|Khu vực\|Jimbo ya\|Lalawigan ng\|Marz\|Mkoa wa\|Penrhyn y\|Talaith\|Tawilayt n\|Tighrmt n\Vostraŭ\|W[iı]lay\(a\|ah\|etê\)\) \('"${P_OF}"'\)*//g' \
            -e 's/^\(Bisbat\|Bishopric\|\([CcÇçSs]\|Tz\)[eiy][uv]*[dt]*[aáàæ][dt]*[e]*[a]*\|[CcKk]o[mn][dt]\(a[dt][o]*\|[eé]\)\|[CcKk][aāo]*[uv]*[nṇ][tṭ][iīy][e]*\|Dakbayan\|Dēmokratía\|[Dd][eéi][sz][iy]*er[tz][ho]*\|[JjŽž]ud[iz]*e[ctțţ]\(ul\)*\|Kaharian\|M[a]*ml[u]*k[a]*ẗ\|Parish\|Pr[ei]n[cgs][ei]p[aáà][dt]*[eou]*\|[Ss]hahrest[aā]n\|Thành\|[Tt][h]*[eé]ma\|[Tt]zountéts\|[VvWw]il[l]*[ae]\(ya\)*\|Xian\) \('"${P_OF}"'\)*//g' \
            \
            -e 's/\(.\)\(bjerget\|shān\|sŏng\)$/\1/g' \
            -e 's/[ ’-]\([Aa]dası\|AG\|[Aa]imag\|[Aa]irurando\|aju\|alue\|[Aa]ñcala\|[Aa]ntic[aă]\|apskritis\|åsene\|[Bb]ar[ou]n[iy][am]*[u]*\|barrutia\|[Bb]hasa\|[Bb]ibhāga\|Bikéyah\|[Bb]isped[øo]m[m]*e\|[Bb]ölgesi\|Bnakavayr\|[Cc]alabro\|çayı\|Chê\|chéng[-]*bǎo\|Chhī\|Chibang\|Chiu\|[Cc]hū-tī\|[CcKk][aāo]*[uv]*[nṇ][tṭ]\([iīy]\|lu[gğ]u]\)\|[cs]h[h]*[ìī]\|Chihō\|[Cc]hiku\|Chiyŏk\|Çölü\|[CcKk]omita[a]*t\(us\)*\|Cumhuriyeti\|[Dd]a[gğ][iı]\|[Dd]ǎo\|dar[ij]a\|Darussalam\|[Dd]evleti\|[Dd]esert\|Dġyak\|Dhāma\|Dimos\|Dzongkhag\|Eḍāri\|[Ee]ennâmkodde\|[Ee]na\|Enez\|[Ee]rusutaa\|[Ee]yaleti\|[Ff]örsamling\|[Gg]aṇarājya\|[Gg]awa\|gielda\|[Gg]o\|[Gg]ōng[ -][Hh]é[ -][Gg]uó\|[Gg]overnorate\|[Gg]rad[ŭ]*\|grubu\|guovlu\|Hahoodzo\|[Hh]albinsel\|hálvoyggin\|Hantou\|He\|Hyŏn\|[Ii]baia\|[Ii]ngurando\|[Jj]ach'"'"'a\|[Jj]anarajaya\|jõgi\|[Jj][iù]n\|jūnōu\|[Kk]a [KkQq]ila\|kaavpug\|ǩalaḥy\|[Kk]alāpaya\|[Kk]alni\|Kang\|Kàēyt Brì Hăān Pí Sàēyt\|kansallispuisto\|[Kk]àu-khu\|ke[e]*l['"'"']*\|[Kk]hiung[ -][Ff]ò[ -][Kk]oet\|[Kk]örzet\|\|[Kk]ōṭṭai\|khoig\|[Kk]hot\|[Kk]hu\|[Kk][iy][i]*l\|Kilisesi\|[Kk]o[aā]n\|Koku\|[Kk]onderria\|község\|[Kk]rallığı\|[Kk]shetr\|Kūn\|Kyouku\|Kyouwa Koku\|lääni\|linn\|maak[ou]n[dt]a*\|[Mm]achi\|[Mm]ahal[iı]\|Mākāṇam\|Mānakaram\|Maṇḍalam\|Marubhūmi\|Māvaṭṭam\|[Mm]arz\|[Mm]e[dg][iy]e\|mhuriyeti\|[Mm]oḻi\|[Mm]ovy\|Mura\|Nadi\|Nagar\(am\)*\|Nakaram\|Nakhevark[’]*undzuli\|[Nn]aturreservat\|Nehri\|Nisí\|osariik\|[Oo]ukoku\|o’zeni\|pagasts\|[Pp]akuti\|[Pp]aḷāta\|Pālaivaṉam\|[Pp]ats’alyg’y\|[Pp]il[i]*s\|piirkonnaüksus\|poolsaar\|qalas[iıy]\|qəsri\|qraflığı\|[Rr]ajonas\|rén\|[Rr]iver\|[SsŠš]aar[iy]*\|Sa[bm]ak[u]*\|[Ss]agrapo\|[sșş][eə]hristan[iı]\|[Ss][h]*i\|Shikyou Ryou\|Shinrinkouen\|[Ss][ho][aā]-[bm][òô͘]*\|[Ss]hou\|Siti\|Shuu\|síksá\|sivatag\|slott\|so\(g\|cke\)n\|sritis\|Sṳ\|sultan\(at[e]*\|lığı\)\|suohkan\|suyu\|tamaneɣt\|[Tt][’]*erakġzi\|tartomány\|[Tt][eē]\|tele\|[Tt]hi-[Kk]hî\|tillari\|[Tt]oshi\|[Tt][oō][au]*\|Town\|tu’begi\|[Uu]da\(bno\|lerria\)\|vald\|VD\|[Vv]ibhāg\|Viru\|VS\|Vương quốc Hồi giáo\|[Ww]amani\|[Ww]áng[ -][Gg]uó\|Wangguk\|[Xx]i[aàā]n[g]*\|\|yǔ\|zh[ēō]*[nu]\|[ZzŽž][h]*ude[ct]s[i]*\|zōng\)$//g' \
            -e 's/[ ’-]\([CcKk]o[ou]*nt\(ae\|luğu\|y\)\|Durg[a]*\|[EeIi]*[Ss][h]*t[’]*a[dt][’]*[eiou]\|[Ff]ylk[ei]\|[GgQq]r[aā]f[l]*[iı]\(ı\|ste\)\|\|[Jj][eēi]l[hl]*[aāeo][a]*\|[Jj][oō][u]*\|[Kk]il[l]*[ao]\|[Mm]a[nṇ][dḍ]al\(a[mṁ]\)*\|[Mm]in[tţ]a[kq]at*\|[Nn]ahan[gk]\|P[aā][i]*ri\(ṣ\|sh\)\|[Oo]blas[tť]\|[Pp]ii\(r\|skop\)kond\|[Pp]lanin[ai]\|[Pp]r[a]*d[eē][sś][h]*[a]*\|[Pp]r[aā]*nt[y]*[a]*\([ṁy][a]*\)*\|[Pp]rja[a]*st[t]*a[a]*k\|[Pp]u[u]*[l]*s[s]*a[al][ar]\|[Rr]eialme\|[Rr][e]*[iī]c[eh]\|[Ss]h[eě]ng\|[Vv]il[aā][jy]\(eti\|s\)\|[ZzŽž]upa\(nija\)*\)$//g' \
            -e 's/[ ’-]\('"${COMMON_PATTERNS}"'\)$//g' \
            -e 's/ [KkCc]om*un*[ea]*$//g' \
            -e 's/ \(Ken\|Koān\)$//g' \
            \
            -e 's/^Hl\. /Heilige /g' \
            -e 's/ mfiadini$/ Mfiadini/g' \
            \
            -e 's/^\(Abhainn\|Afon\|Ri[ou]\) //g' \
            -e 's/^Ducado de l'"\'"'//g' \
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

    echo "${NAME}" | sed \
            -e 's/æ/ae/g' \
            -e 's/\([ČčŠšŽž]\)/\1h/g' \
            -e 's/[Ǧǧ]/j/g' | \
        iconv -f utf8 -t ascii//TRANSLIT | \
        sed 's/-le-/_le_/g' | \
        sed 's/ /_/g' | sed "s/\'//g" | \
        sed 's/['"\'"']//g' | sed "s/\'//g" | \
        sed 's/\(north\|west\|south\|east\)ern/\1/g' | \
        sed 's/^\(north\|west\|south\|east\)_\(.*\)$/\2_\1/g' | \
        tr '[:upper:]' '[:lower:]'
}
