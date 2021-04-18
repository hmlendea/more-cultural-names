#!/bin/bash

STARTDIR="$(pwd)"
OUTDIR="${STARTDIR}/out"
EXTRAS_DIR="${STARTDIR}/extras"
VANILLA_FILES_DIR="${STARTDIR}/vanilla"

BUILD_VERSION=${1}

LANGUAGES_FILE="languages.xml"
LOCATIONS_FILE="locations.xml"
TITLES_FILE="titles.xml"

if [ -z "${VERSION}" ]; then
    BUILD_VERSION=0
fi

VERSION=$(date +"%y").$(date +"%j").${BUILD_VERSION}

MOD_BUILDER_NAME="more-cultural-names-builder"
MOD_BUILDER_VERSION=$(curl --silent "https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/latest" | sed 's/.*\/tag\/v\([^\"]*\)">redir.*/\1/g')
MOD_BUILDER_ZIP_URL="https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/download/v${MOD_BUILDER_VERSION}/${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip"
MOD_BUILDER_BIN_FILE_PATH="${STARTDIR}/${MOD_BUILDER_NAME}/MoreCulturalNamesModBuilder"
NEEDS_DOWNLOADING=true

if [[ $* != *--skip-updates* ]]; then
    echo "Checking for builder updates..."
    if [ -d "${STARTDIR}/${MOD_BUILDER_NAME}" ]; then
        if [ -f "${STARTDIR}/${MOD_BUILDER_NAME}/version.txt" ]; then
            CURRENT_VERSION=$(cat "${STARTDIR}/${MOD_BUILDER_NAME}/version.txt")
            if [ "${CURRENT_VERSION}" == "${MOD_BUILDER_VERSION}" ]; then
                NEEDS_DOWNLOADING=false
            fi
        fi
    fi

    if [ ${NEEDS_DOWNLOADING} == true ]; then
        [ -d "${STARTDIR}/${MOD_BUILDER_NAME}" ] && rm -rf "${STARTDIR}/${MOD_BUILDER_NAME}"

        wget -c "${MOD_BUILDER_ZIP_URL}"
        mkdir "${STARTDIR}/${MOD_BUILDER_NAME}"
        unzip "${STARTDIR}/${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip" -d "${STARTDIR}/${MOD_BUILDER_NAME}"
        echo "${MOD_BUILDER_VERSION}" > "${STARTDIR}/${MOD_BUILDER_NAME}/version.txt"
    fi
fi

echo "Validating the files..."
VALIDATE_DATA="$(bash scripts/validate-data.sh | tr '\0' '\n')"
if [ -n "${VALIDATE_DATA}" ]; then
    echo "Input files validation failed!"
    echo "${VALIDATE_DATA}"
    exit 1
fi

function build-edition {
    ID="${1}"
    NAME="${2}"
    GAME="${3}"
    GAME_VERSION="${4}"
    EXTRA_ARGS=${@:5}

    PACKAGE_NAME="mcn_${GAME}_${VERSION}"
    ORIGINAL_WORKING_DIRECTORY=$(pwd)

    [ -d "${OUTDIR}/${GAME}" ] && rm -rf "${OUTDIR}/${GAME}"
    [ -f "${OUTDIR}/${PACKAGE_NAME}.zip" ] && rm "${OUTDIR}/${PACKAGE_NAME}.zip"

    cd "${STARTDIR}"
    "${MOD_BUILDER_BIN_FILE_PATH}" \
        --lang "${LANGUAGES_FILE}" \
        --loc "${LOCATIONS_FILE}" \
        --titles "${TITLES_FILE}" \
        --game "${GAME}" --game-version "${GAME_VERSION}" \
        --id "${ID}" --name "${NAME}" --ver "${VERSION}" \
        --out "${OUTDIR}" ${EXTRA_ARGS}

    echo "   > Copying extras..."
    cp -rf "${EXTRAS_DIR}/${GAME}"/* "${OUTDIR}/${GAME}/"

    echo "   > Building the package..."
    cd "${OUTDIR}/${GAME}"
    zip -q -r "${PACKAGE_NAME}.zip" ./*
    mv "${PACKAGE_NAME}.zip" "${OUTDIR}/${PACKAGE_NAME}.zip"

    cd "${ORIGINAL_WORKING_DIRECTORY}"
}

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "CK2" "3.3.3" \
    --landed-titles "vanilla//ck2_landed_titles.txt" --landed-titles-name "landed_titles.txt"

build-edition \
    "hip-more-cultural-names" "HIP-More Cultural Names" \
    "CK2HIP" "Frosty3" \
    --landed-titles "vanilla/ck2hip_landed_titles.txt" --landed-titles-name "swmh_landed_titles.txt" \
    --dep HIP\ -\ Historical\ Immersion\ Project

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "CK3" "1.3.*" \
    --landed-titles "vanilla/ck3_landed_titles.txt" --landed-titles-name "999_MoreCulturalNames.txt"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "HOI4" "1.10.*"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "ImperatorRome" "2.0.*"

cd "${STARTDIR}"
bash "${STARTDIR}/scripts/count-localisations.sh"

echo ""
echo "Mod version: ${VERSION}"
