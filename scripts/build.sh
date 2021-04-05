#!/bin/bash

STARTDIR="$(pwd)"
OUTDIR="${STARTDIR}/out"
BUILD_VERSION=${1}

LANGUAGES_FILE="languages.xml"
LOCATIONS_FILE="locations.xml"
TITLES_FILE="titles.xml"

if [ -z "${VERSION}" ]; then
    BUILD_VERSION=0
fi

VERSION=$(date +"%y").$(date +"%j").${BUILD_VERSION}

echo "Mod version: ${VERSION}"

echo "Validating the files..."
VALIDATE_DATA="$(sh scripts/validate-data.sh | tr '\0' '\n')"
if [ -n "${VALIDATE_DATA}" ]; then
    echo "Input files validation failed!"
    echo "${VALIDATE_DATA}"
    exit 1
fi

MOD_BUILDER_NAME="more-cultural-names-builder"
MOD_BUILDER_VERSION=$(curl --silent "https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/latest" | sed 's/.*\/tag\/v\([^\"]*\)">redir.*/\1/g')
MOD_BUILDER_ZIP_URL="https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/download/v${MOD_BUILDER_VERSION}/${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip"
MOD_BUILDER_BIN_FILE_PATH="${MOD_BUILDER_NAME}/MoreCulturalNamesModBuilder"
NEEDS_DOWNLOADING=true

echo "Checking for builder updates..."
if [ -d ${MOD_BUILDER_NAME} ]; then
    if [ -f ${MOD_BUILDER_NAME}/version.txt ]; then
        CURRENT_VERSION=$(cat ${MOD_BUILDER_NAME}/version.txt)
        if [ "${CURRENT_VERSION}" == "${MOD_BUILDER_VERSION}" ]; then
            NEEDS_DOWNLOADING=false
        fi
    fi
fi

if [ ${NEEDS_DOWNLOADING} == true ]; then
    [ -d ${MOD_BUILDER_NAME} ] && rm -rf ${MOD_BUILDER_NAME}

    wget -c ${MOD_BUILDER_ZIP_URL}
    mkdir ${MOD_BUILDER_NAME}
    unzip ${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip -d ${MOD_BUILDER_NAME}
    echo ${MOD_BUILDER_VERSION} > ${MOD_BUILDER_NAME}/version.txt
fi

[ -d "out/" ] && rm -rf "out/"

echo "Building..."
${MOD_BUILDER_BIN_FILE_PATH} \
    --lang "${LANGUAGES_FILE}" \
    --loc "${LOCATIONS_FILE}" \
    --titles "${TITLES_FILE}" \
    --ver ${VERSION} \
    --out "out/"

cp -rf extras/ck2/* out/CK2/
cp -rf extras/ck2hip/* out/CK2HIP/
cp -rf extras/ck3/* out/CK3/
cp -rf extras/hoi4/* out/HOI4/
cp -rf extras/ir/* out/ImperatorRome/

function package-game {
    GAME=${1}
    INDIR="out/${GAME}/"
    ZIPNAME=${GAME}_${VERSION}

    echo "Building the '${INDIR}' package..."

    cd "${STARTDIR}/${INDIR}"
    zip -q -r "${ZIPNAME}.zip" ./*
    mv "${ZIPNAME}.zip" "${OUTDIR}/"
}

package-game "CK2"
package-game "CK2HIP"
package-game "CK3"
package-game "HOI4"
package-game "ImperatorRome"

cd "${STARTDIR}"
bash "${STARTDIR}/scripts/count-localisations.sh"

echo "Mod version: ${VERSION}"
