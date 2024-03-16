#!/bin/bash
source "scripts/common/paths.sh"

BUILD_VERSION="${1}"
BUILDER_VERSION=""

[ -f "${REPO_DIR}/.builder/version.txt" ] && BUILDER_VERSION=$(cat "${REPO_DIR}/.builder/version.txt")

if [ -z "${BUILD_VERSION}" ] || ! [[ ${BUILD_VERSION} =~ ^[0-9]+$ ]]; then
    BUILD_VERSION=0
fi

VERSION=$(date +"%y").$(date +"%j").${BUILD_VERSION}

CONTENT_CHECKSUM=$(cat "${REPO_DIR}"/*.xml | sha512sum)
CHECKSUM=$(echo "${CONTENT_CHECKSUM} ${VERSION} ${BUILDER_VERSION}" | sha512sum | awk '{print $1}')

if [[ $* != *--skip-update* ]] \
&& [[ $* != *--skip-updates* ]]; then
    bash "${SCRIPTS_DIR}/update-builder.sh"
    bash "${SCRIPTS_DIR}/update-vanilla-files.sh"
fi

if [[ $* != *--skip-validation* ]] \
&& [[ $* != *--skip-validations* ]]; then
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
    local EDITION_CHECKSUM_FILE="${EDITION_DIR}/checksum.sha512"
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
    "CK3" "1.11.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3_landed_titles.txt" --landed-titles-name "999_MoreCulturalNames.txt"

build-edition \
    "aep-more-cultural-names" "Asia Expansion Project - More Cultural Names" \
    "CK3AEP" "1.12.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3aep_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "atha-more-cultural-names" "Apotheosis: More Cultural Names" \
    "CK3ATHA" "1.9.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3atha_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "ce-more-cultural-names" "Culture Expanded - More Cultural Names" \
    "CK3CE" "1.11.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3ce_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "cmh-more-cultural-names" "Community Mods for Historicity - More Cultural Names" \
    "CK3CMH" "1.8.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3cmh_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "ibl-more-cultural-names" "Ibn Battuta's Legacy 2 - More Cultural Names" \
    "CK3IBL" "1.12.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3ibl_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "mbp-more-cultural-names" "More Bookmarks+ - More Cultural Names" \
    "CK3MBP" "1.12.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3mbp_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "sow-more-cultural-names" "Sinews of War - More Cultural Names" \
    "CK3SoW" "1.8.*" \
    --landed-titles "${CK3SoW_VANILLA_LANDED_TITLES_FILE}" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "tba-more-cultural-names" "The Bronze Age: More Cultural Names" \
    "CK3TBA" "1.2.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3tba_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "tfe-more-cultural-names" "The Fallen Eagle - More Cultural Names" \
    "CK3TFE" "1.11.*" \
    --landed-titles "${VANILLA_FILES_DIR}/ck3tfe_landed_titles.txt" --landed-titles-name "873_MoreCulturalNames.txt"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "HOI4" "1.13.*"

build-edition \
    "mdm-more-cultural-names" "Millennium Dawn: More Cultural Names" \
    "HOI4MDM" "1.13.*" \
    --dependency "Millennium Dawn: A Modern Day Mod"

build-edition \
    "tgw-more-cultural-names" "The Great War: More Cultural Names" \
    "HOI4TGW" "1.13.*"

build-edition \
    "more-cultural-names" "More Cultural Names" \
    "IR" "2.0.*"

build-edition \
    "abw-more-cultural-names" "A Broken World: More Cultural Names" \
    "IR_ABW" "2.0.*"

build-edition \
    "aoe-more-cultural-names" "Ashes of Empire: More Cultural Names" \
    "IR_AoE" "2.0.*"

build-edition \
    "inv-more-cultural-names" "Imperator: Invictus - More Cultural Names" \
    "IR_INV" "2.0.*"

build-edition \
    "tba-more-cultural-names" "The Bronze Age: More Cultural Names" \
    "IR_TBA" "2.0.*"

cd "${REPO_DIR}"
bash "${REPO_DIR}/scripts/count-localisations.sh"

echo ""
echo "Mod version: ${VERSION}"
