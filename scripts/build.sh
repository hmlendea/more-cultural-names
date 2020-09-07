#!/bin/bash

echo "Validating the files..."
if [ -n "$(sh scripts/find-mistakes.sh)" ]; then
    echo "Input files validation failed!"
    exit 1
fi

MOD_BUILDER_NAME="more-cultural-names-builder"
MOD_BUILDER_VERSION=$(curl --silent "https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/latest" | sed 's/.*\/tag\/v\([^\"]*\)">redir.*/\1/g')
MOD_BUILDER_ZIP_URL="https://github.com/hmlendea/${MOD_BUILDER_NAME}/releases/download/v${MOD_BUILDER_VERSION}/${MOD_BUILDER_NAME}_${MOD_BUILDER_VERSION}_linux-x64.zip"
MOD_BUILDER_BIN_FILE_PATH="${MOD_BUILDER_NAME}/MoreCulturalNamesModBuilder"
NEEDS_DOWNLOADING=true

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

${MOD_BUILDER_BIN_FILE_PATH} -l "languages.xml" -t "titles.xml" -o "out/"ld

cp -rf extras/ck2hip/* out/CK2HIP/
cp -rf extras/ck3/* out/CK3/
cp -rf extras/ir/* out/ImperatorRome/
