#!/bin/bash

STARTDIR="$(pwd)"
SCRIPTSDIR="${STARTDIR}/scripts"
OUTDIR="${STARTDIR}/out"
EXTRAS_DIR="${STARTDIR}/extras"
VANILLA_FILES_DIR="${STARTDIR}/vanilla"

BUILD_VERSION="${1}"

LANGUAGES_FILE="languages.xml"
LOCATIONS_FILE="locations.xml"
TITLES_FILE="titles.xml"

if [ -z "${BUILD_VERSION}" ] || ! [[ ${BUILD_VERSION} =~ ^[0-9]+$ ]]; then
    BUILD_VERSION=0
fi

VERSION=$(date +"%y").$(date +"%j").${BUILD_VERSION}

if [[ $* != *--skip-updates* ]]; then
    bash "${SCRIPTSDIR}/update-builder.sh"
    bash "${SCRIPTSDIR}/update-vanilla-files.sh"
fi

if [[ $* != *--skip-validation* ]]; then
    echo "Validating the files..."
    VALIDATE_DATA="$(bash scripts/validate-data.sh | tr '\0' '\n')"
    if [ -n "${VALIDATE_DATA}" ]; then
        echo "Input files validation failed!"
        echo "${VALIDATE_DATA}"
        exit 1
    fi
fi

function build-edition {
    ID="${1}" && shift
    NAME="${1}" && shift
    GAME="${1}" && shift
    GAME_VERSION="${1}" && shift

    PACKAGE_NAME="mcn_${GAME}_${VERSION}"
    ORIGINAL_WORKING_DIRECTORY=$(pwd)

    [ -d "${OUTDIR}/${GAME}" ] && rm -rf "${OUTDIR:?}/${GAME:?}"
    [ -f "${OUTDIR}/${PACKAGE_NAME}.zip" ] && rm "${OUTDIR}/${PACKAGE_NAME}.zip"

    cd "${STARTDIR}"
    "${STARTDIR}/.builder/MoreCulturalNamesModBuilder" \
        --lang "${LANGUAGES_FILE}" \
        --loc "${LOCATIONS_FILE}" \
        --titles "${TITLES_FILE}" \
        --game "${GAME}" --game-version "${GAME_VERSION}" \
        --id "${ID}" --name "${NAME}" --ver "${VERSION}" \
        --out "${OUTDIR}" "$@"

    if [ ! -d "${OUTDIR}/${GAME}/" ]; then
        echo "   > ERROR: Failed to build the ${GAME} edition!"
        exit 200
    fi

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
    "CK2" "3.3.5.1" \
    --landed-titles "${VANILLA_FILES_DIR}/ck2_landed_titles.txt" --landed-titles-name "landed_titles.txt"

build-edition \
    "hip-more-cultural-names" "HIP - More Cultural Names" \
    "CK2HIP" "Frosty3" \
    --landed-titles "${VANILLA_FILES_DIR}/ck2hip_landed_titles.txt" --landed-titles-name "swmh_landed_titles.txt" \
    --dep "HIP - Historical Immersion Project"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "CK3" "1.4.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3_landed_titles.txt" --landed-titles-name "999_MoreCulturalNames.txt"

build-edition \
    "ibl-more-cultural-names" "Ibn Battuta's Legacy 2 - More Cultural Names" \
    "CK3IBL" "1.4.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3ibl_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "mbp-more-cultural-names" "More Bookmarks+ - More Cultural Names" \
    "CK3MBP" "1.4.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3mbp_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "tfe-more-cultural-names" "The Fallen Eagle: More Cultural Names" \
    "CK3TFE" "1.4.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3tfe_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "HOI4" "1.11.*"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "ImperatorRome" "2.0.*"

cd "${STARTDIR}"
bash "${STARTDIR}/scripts/count-localisations.sh"

echo ""
echo "Mod version: ${VERSION}"
