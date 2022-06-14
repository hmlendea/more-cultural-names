#!/bin/bash
source "scripts/common/paths.sh"

BUILD_VERSION="${1}"
BUILDER_VERSION=""

[ -f "${REPO_DIR}/.builder/version.txt" ] && BUILDER_VERSION=$(cat "${REPO_DIR}/.builder/version.txt")

DATA_CONTENT=$(cat "${REPO_DIR}"/*.xml)
CHECKSUM=$(echo "${CHECKSUM_SEED} ${BUILDER_VERSION}" | sha512sum | awk '{print $1}')

if [ -z "${BUILD_VERSION}" ] || ! [[ ${BUILD_VERSION} =~ ^[0-9]+$ ]]; then
    BUILD_VERSION=0
fi

VERSION=$(date +"%y").$(date +"%j").${BUILD_VERSION}

if [[ $* != *--skip-updates* ]]; then
    bash "${SCRIPTS_DIR}/update-builder.sh"
    bash "${SCRIPTS_DIR}/update-vanilla-files.sh"
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
    local ID="${1}" && shift
    local NAME="${1}" && shift
    local GAME="${1}" && shift
    local GAME_VERSION="${1}" && shift

    local PACKAGE_NAME="mcn_${GAME}_${VERSION}"
    local EDITION_DIR="${OUTPUT_DIR}/${GAME}"
    local EDITION_PACKAGE="${OUTPUT_DIR}/${PACKAGE_NAME}.zip"
    local EDITION_CHECKSUM_FILE="${EDITION_DIR}/mcn.sha512"
    local ORIGINAL_WORKING_DIRECTORY=$(pwd)

    if [ -d "${EDITION_DIR}" ] \
    || [ -f "${EDITION_PACKAGE}" ]; then
        local EDITION_CHECKSUM=""
        [ -f "${EDITION_CHECKSUM_FILE}" ] && EDITION_CHECKSUM=$(cat "${EDITION_CHECKSUM_FILE}")

        if [[ "${EDITION_CHECKSUM}" == "${CHECKSUM}" ]]; then
            echo "   > INFO: The ${GAME} edition was already built. Skipping..."
            return
        else
            [ -d "${EDITION_DIR}" ] && rm -rf "${OUTPUT_DIR:?}/${GAME:?}"
            [ -f "${EDITION_PACKAGE}" ] && rm "${EDITION_PACKAGE}"
            [ -f "${EDITION_CHECKSUM_FILE}" ] && rm "${EDITION_CHECKSUM_FILE}"
        fi
    fi

    cd "${REPO_DIR}"
    "${REPO_DIR}/.builder/MoreCulturalNamesBuilder" \
        --lang "${LANGUAGES_FILE}" \
        --loc "${LOCATIONS_FILE}" \
        --titles "${TITLES_FILE}" \
        --game "${GAME}" --game-version "${GAME_VERSION}" \
        --id "${ID}" --name "${NAME}" --ver "${VERSION}" \
        --out "${OUTPUT_DIR}" "$@"

    if [ ! -d "${EDITION_DIR}/" ]; then
        echo "   > ERROR: Failed to build the ${GAME} edition!"
        exit 200
    fi

    echo "   > Copying extras..."
    cp -rf "${EXTRAS_DIR}/${GAME}"/* "${EDITION_DIR}/"

    echo "   > Building the package..."
    cd "${EDITION_DIR}"
    zip -q -r "${PACKAGE_NAME}.zip" "./${ID}" "./${ID}.mod"
    mv "${PACKAGE_NAME}.zip" "${EDITION_PACKAGE}"

    cd "${ORIGINAL_WORKING_DIRECTORY}"

    echo "${CHECKSUM}" > "${EDITION_CHECKSUM_FILE}"
}


build-edition \
    "sow-more-cultural-names" "Sinews of War - More Cultural Names" \
    "CK3SoW" "1.6.*" \
    --landed-titles "${CK3SoW_VANILLA_LANDED_TITLES_FILE}" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "tba-more-cultural-names" "The Bronze Age: More Cultural Names" \
    "CK3TBA" "1.2.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3tba_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

cd "${REPO_DIR}"
bash "${REPO_DIR}/scripts/count-localisations.sh"

echo ""
echo "Mod version: ${VERSION}"
